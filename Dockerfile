# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:zed@sha256:06cf3ff9c80df7e2ea4db9238a323e1091c3ed4689005c8b9455072380a4febf AS build
RUN --mount=type=bind,from=placement,source=/,target=/src/placement,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/placement
EOF

FROM ghcr.io/vexxhost/python-base:zed@sha256:6bad9c96495b05ad8501995922acdc3f02a9ce09dbdfa7a0affb33aa0b94f260
RUN \
    groupadd -g 42424 placement && \
    useradd -u 42424 -g 42424 -M -d /var/lib/placement -s /usr/sbin/nologin -c "Placement User" placement && \
    mkdir -p /etc/placement /var/log/placement /var/lib/placement /var/cache/placement && \
    chown -Rv placement:placement /etc/placement /var/log/placement /var/lib/placement /var/cache/placement
COPY --from=build --link /var/lib/openstack /var/lib/openstack
