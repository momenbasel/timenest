"""Very small session-based auth for the admin UI.

We intentionally keep this single-user. TimeNest is meant to live on a
home LAN behind a VPN; multi-admin RBAC would be overkill and a larger
attack surface.
"""

from __future__ import annotations

import secrets
from typing import Callable

from fastapi import Depends, HTTPException, Request, status
from passlib.hash import bcrypt

from .config import Settings


def verify_login(username: str, password: str, settings: Settings) -> bool:
    """Constant-time comparison of credentials against the configured admin."""
    user_ok = secrets.compare_digest(username, settings.admin_user)
    # bcrypt.verify handles its own timing; hash the configured password
    # once on startup rather than re-hashing per request. Done lazily in
    # _admin_hash below.
    pass_ok = bcrypt.verify(password, _admin_hash(settings))
    return user_ok and pass_ok


_cached_hash: str | None = None


def _admin_hash(settings: Settings) -> str:
    global _cached_hash
    if _cached_hash is None:
        _cached_hash = bcrypt.hash(settings.admin_password)
    return _cached_hash


def require_login(request: Request) -> str:
    """FastAPI dependency that redirects to /login if the session is missing."""
    user = request.session.get("user")
    if not user:
        raise HTTPException(
            status_code=status.HTTP_303_SEE_OTHER,
            headers={"Location": "/login"},
        )
    return user


LoginDep: Callable[..., str] = Depends(require_login)
