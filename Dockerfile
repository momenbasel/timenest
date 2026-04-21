# Multi-stage, multi-arch Dockerfile for the Samba and Avahi services.
#
# Target "samba" produces a Debian-slim image with Samba 4.18+, vfs_fruit,
# and the TimeNest entrypoint that renders smb.conf from env vars.
#
# Target "avahi" produces a smaller image with just avahi-daemon and the
# TimeNest service file, also rendered from env vars at start.
#
# Built for linux/amd64, linux/arm64, and linux/arm/v7 via buildx in CI.

ARG DEBIAN_VERSION=bookworm-slim

# ---------------------------------------------------------------------------
# Stage: samba
# ---------------------------------------------------------------------------
FROM debian:${DEBIAN_VERSION} AS samba

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        samba \
        samba-vfs-modules \
        smbclient \
        attr \
        acl \
        tini \
        tzdata \
        ca-certificates \
        gettext-base \
        procps \
 && rm -rf /var/lib/apt/lists/*

COPY samba/smb.conf.template /etc/timenest/smb.conf.template
COPY scripts/entrypoint-samba.sh /usr/local/bin/entrypoint-samba.sh
COPY scripts/create-user.sh     /usr/local/bin/create-user.sh
COPY scripts/delete-user.sh     /usr/local/bin/delete-user.sh
RUN chmod +x /usr/local/bin/entrypoint-samba.sh \
             /usr/local/bin/create-user.sh \
             /usr/local/bin/delete-user.sh

EXPOSE 445

VOLUME ["/backup", "/var/lib/samba", "/etc/timenest"]

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/entrypoint-samba.sh"]

# ---------------------------------------------------------------------------
# Stage: avahi
# ---------------------------------------------------------------------------
FROM debian:${DEBIAN_VERSION} AS avahi

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        avahi-daemon \
        avahi-utils \
        libnss-mdns \
        tini \
        tzdata \
        gettext-base \
        ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY avahi/timenest.service.template /etc/timenest/timenest.service.template
COPY avahi/avahi-daemon.conf /etc/avahi/avahi-daemon.conf
COPY scripts/entrypoint-avahi.sh /usr/local/bin/entrypoint-avahi.sh
RUN chmod +x /usr/local/bin/entrypoint-avahi.sh

EXPOSE 5353/udp

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/entrypoint-avahi.sh"]
