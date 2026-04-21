"""Runtime configuration loaded from environment variables."""

from functools import lru_cache
from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """All tunables live here so the rest of the app sees typed values."""

    model_config = SettingsConfigDict(env_file=None, extra="ignore")

    admin_user: str = Field(default="admin", alias="ADMIN_USER")
    admin_password: str = Field(alias="ADMIN_PASSWORD")

    backup_path: Path = Field(default=Path("/backup"), alias="BACKUP_PATH")
    default_quota_gb: int = Field(default=500, alias="DEFAULT_QUOTA_GB")

    samba_container: str = Field(default="timenest-samba", alias="SAMBA_CONTAINER")
    samba_data_path: Path = Field(default=Path("/samba"), alias="SAMBA_DATA_PATH")

    enable_metrics: bool = Field(default=True, alias="ENABLE_METRICS")
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")
    timezone: str = Field(default="UTC", alias="TZ")

    data_dir: Path = Field(default=Path("/data"), alias="DATA_DIR")
    session_secret: str | None = Field(default=None, alias="SESSION_SECRET")


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()  # type: ignore[call-arg]
