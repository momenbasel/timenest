"""FastAPI entrypoint for the TimeNest web UI."""

from __future__ import annotations

import logging
import secrets
from pathlib import Path

from fastapi import Depends, FastAPI, Form, HTTPException, Request, status
from fastapi.responses import HTMLResponse, RedirectResponse, Response
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware

from . import disks, metrics, samba_mgr
from .auth import LoginDep, verify_login
from .config import Settings, get_settings

# ---------------------------------------------------------------------------
# App wiring
# ---------------------------------------------------------------------------
app = FastAPI(title="TimeNest", docs_url=None, redoc_url=None)

settings = get_settings()

logging.basicConfig(
    level=getattr(logging, settings.log_level.upper(), logging.INFO),
    format="[%(asctime)s] [%(levelname)s] %(name)s: %(message)s",
)
log = logging.getLogger("timenest.web")

# Session secret persists across restarts so users don't get logged out on
# container updates. Generated once and stashed alongside the data volume.
session_secret = settings.session_secret
if not session_secret:
    secret_file = settings.data_dir / ".session_secret"
    try:
        settings.data_dir.mkdir(parents=True, exist_ok=True)
        if secret_file.exists():
            session_secret = secret_file.read_text().strip()
        else:
            session_secret = secrets.token_urlsafe(64)
            secret_file.write_text(session_secret)
            secret_file.chmod(0o600)
    except OSError:
        session_secret = secrets.token_urlsafe(64)

app.add_middleware(
    SessionMiddleware,
    secret_key=session_secret,
    session_cookie="timenest_session",
    max_age=60 * 60 * 24 * 7,
    same_site="lax",
    https_only=False,  # reverse proxy handles TLS; flip to True behind https
)

_static_dir = Path(__file__).resolve().parent.parent / "static"
app.mount("/static", StaticFiles(directory=_static_dir), name="static")

_templates_dir = Path(__file__).resolve().parent / "templates"
templates = Jinja2Templates(directory=_templates_dir)
templates.env.globals["version"] = "0.1.0"
templates.env.globals["server_name"] = settings.admin_user


def _mgr() -> samba_mgr.SambaManager:
    return samba_mgr.SambaManager(settings)


def _fmt_bytes(n: int | None) -> str:
    if n is None:
        return "-"
    for unit in ("B", "KB", "MB", "GB", "TB", "PB"):
        if n < 1024 or unit == "PB":
            return f"{n:.1f} {unit}" if unit != "B" else f"{n} B"
        n /= 1024  # type: ignore[assignment]
    return f"{n} PB"


def _fmt_ts(ts: int | None) -> str:
    if not ts:
        return "never"
    import datetime as _dt
    return _dt.datetime.fromtimestamp(ts).strftime("%Y-%m-%d %H:%M")


templates.env.filters["bytes"] = _fmt_bytes
templates.env.filters["ts"] = _fmt_ts


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/login", response_class=HTMLResponse)
def login_form(request: Request) -> Response:
    if request.session.get("user"):
        return RedirectResponse("/", status_code=status.HTTP_303_SEE_OTHER)
    return templates.TemplateResponse("login.html", {"request": request, "error": None})


@app.post("/login", response_class=HTMLResponse)
def login_submit(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    cfg: Settings = Depends(get_settings),
) -> Response:
    if not verify_login(username, password, cfg):
        log.warning("failed login for '%s' from %s", username, request.client.host if request.client else "?")
        return templates.TemplateResponse(
            "login.html",
            {"request": request, "error": "Invalid credentials"},
            status_code=status.HTTP_401_UNAUTHORIZED,
        )
    request.session["user"] = username
    log.info("login ok: %s", username)
    return RedirectResponse("/", status_code=status.HTTP_303_SEE_OTHER)


@app.get("/logout")
def logout(request: Request) -> Response:
    request.session.clear()
    return RedirectResponse("/login", status_code=status.HTTP_303_SEE_OTHER)


@app.get("/", response_class=HTMLResponse)
async def dashboard(request: Request, user: str = LoginDep) -> Response:
    mgr = _mgr()
    users = mgr.list_users()
    sessions = await mgr.list_sessions()
    du = disks.usage(settings.backup_path)
    return templates.TemplateResponse(
        "dashboard.html",
        {
            "request": request,
            "page": "dashboard",
            "users": users,
            "sessions": sessions,
            "disk": du,
            "backup_path": str(settings.backup_path),
            "server_name": settings.admin_user,
        },
    )


@app.get("/users", response_class=HTMLResponse)
def users_page(request: Request, user: str = LoginDep) -> Response:
    return templates.TemplateResponse(
        "users.html",
        {
            "request": request,
            "page": "users",
            "users": _mgr().list_users(),
            "default_quota_gb": settings.default_quota_gb,
            "created": request.query_params.get("created"),
            "deleted": request.query_params.get("deleted"),
            "error": request.query_params.get("error"),
        },
    )


@app.post("/users")
async def users_create(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    quota_gb: int = Form(...),
    user: str = LoginDep,
) -> Response:
    try:
        await _mgr().create_user(username, password, quota_gb)
    except (ValueError, RuntimeError) as exc:
        return RedirectResponse(
            f"/users?error={exc}",
            status_code=status.HTTP_303_SEE_OTHER,
        )
    log.info("created user '%s' (%d GB quota)", username, quota_gb)
    return RedirectResponse(
        f"/users?created={username}",
        status_code=status.HTTP_303_SEE_OTHER,
    )


@app.post("/users/{username}/delete")
async def users_delete(
    username: str,
    purge: str = Form(default=""),
    user: str = LoginDep,
) -> Response:
    try:
        await _mgr().delete_user(username, purge=bool(purge))
    except (ValueError, RuntimeError) as exc:
        raise HTTPException(400, str(exc))
    log.info("deleted user '%s' (purge=%s)", username, bool(purge))
    return RedirectResponse(
        f"/users?deleted={username}",
        status_code=status.HTTP_303_SEE_OTHER,
    )


@app.get("/disks", response_class=HTMLResponse)
async def disks_page(request: Request, user: str = LoginDep) -> Response:
    du = disks.usage(settings.backup_path)
    # Probe common device paths. Missing devices simply show "unavailable".
    smart_results = []
    for dev in _probe_devices():
        status_ = await disks.smart(dev)
        if status_:
            smart_results.append(status_)
    return templates.TemplateResponse(
        "disks.html",
        {
            "request": request,
            "page": "disks",
            "disk": du,
            "smart": smart_results,
            "backup_path": str(settings.backup_path),
        },
    )


@app.get("/settings", response_class=HTMLResponse)
def settings_page(request: Request, user: str = LoginDep) -> Response:
    return templates.TemplateResponse(
        "settings.html",
        {
            "request": request,
            "page": "settings",
            "settings": {
                "admin_user": settings.admin_user,
                "backup_path": str(settings.backup_path),
                "default_quota_gb": settings.default_quota_gb,
                "log_level": settings.log_level,
                "timezone": settings.timezone,
                "enable_metrics": settings.enable_metrics,
            },
        },
    )


@app.get("/metrics")
async def metrics_endpoint() -> Response:
    if not settings.enable_metrics:
        raise HTTPException(404, "metrics disabled")
    body = await metrics.render(settings, _mgr())
    return Response(body, media_type=metrics.CONTENT_TYPE)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _probe_devices() -> list[str]:
    """Enumerate likely disk device nodes in a sensible order.

    On Raspberry Pi the backup drive is typically /dev/sda; on NUCs and
    generic Linux boxes it is /dev/sdb; on Mac mini we skip because the
    container cannot read raw disk devices through Docker Desktop.
    """
    import os
    candidates = []
    for p in ("/dev/sda", "/dev/sdb", "/dev/sdc", "/dev/nvme0n1", "/dev/nvme1n1"):
        if os.path.exists(p):
            candidates.append(p)
    return candidates
