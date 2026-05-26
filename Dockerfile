# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:main@sha256:27272877c44975c81021075d807960ce9c2cf1be47e709334c4961257c2ca432 AS build
RUN --mount=type=bind,from=placement,source=/,target=/src/placement,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/placement
EOF

FROM ghcr.io/vexxhost/python-base:main@sha256:db84eb684023891a9e89087b8cf47a6b628ab6161c797bbac50c8b8979ed1492
RUN \
    groupadd -g 42424 placement && \
    useradd -u 42424 -g 42424 -M -d /var/lib/placement -s /usr/sbin/nologin -c "Placement User" placement && \
    mkdir -p /etc/placement /var/log/placement /var/lib/placement /var/cache/placement && \
    chown -Rv placement:placement /etc/placement /var/log/placement /var/lib/placement /var/cache/placement
COPY --from=build --link /var/lib/openstack /var/lib/openstack
