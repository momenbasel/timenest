FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

ARG TARGETARCH
ARG DOCKER_CLI_VERSION=27.3.1

# We need the docker CLI (only, not the daemon) so the web container can run
# `docker exec timenest-samba ...` against the host docker.sock. The Debian
# `docker.io` package pulls in the full daemon (~200 MB) and was unreliable on
# slim arm64 (issue #3: FileNotFoundError on the `docker` binary). Pulling the
# static CLI build from download.docker.com gives us a single 30 MB binary
# that works identically on amd64 and arm64.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl smartmontools ca-certificates tini; \
    case "${TARGETARCH:-amd64}" in \
        amd64) dockerArch=x86_64 ;; \
        arm64) dockerArch=aarch64 ;; \
        *) echo "unsupported TARGETARCH ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL "https://download.docker.com/linux/static/stable/${dockerArch}/docker-${DOCKER_CLI_VERSION}.tgz" \
        -o /tmp/docker.tgz; \
    tar -xzf /tmp/docker.tgz -C /tmp; \
    install -m 0755 /tmp/docker/docker /usr/local/bin/docker; \
    rm -rf /tmp/docker /tmp/docker.tgz; \
    docker --version; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app ./app
COPY static ./static

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -fsS http://localhost:8080/health || exit 1

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080", "--proxy-headers", "--forwarded-allow-ips=*"]
