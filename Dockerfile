# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:main@sha256:3d9b22eb99c65033fd3cbf1647fa53f4b51a2fc00a1f6af54c967e3fff525e7b AS build
RUN --mount=type=bind,from=placement,source=/,target=/src/placement,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/placement
EOF

FROM ghcr.io/vexxhost/python-base:main@sha256:2e16855b7d95781de7396ac2cac3aef32ca5a83079db724e3f97d4e4be322c94
RUN \
    groupadd -g 42424 placement && \
    useradd -u 42424 -g 42424 -M -d /var/lib/placement -s /usr/sbin/nologin -c "Placement User" placement && \
    mkdir -p /etc/placement /var/log/placement /var/lib/placement /var/cache/placement && \
    chown -Rv placement:placement /etc/placement /var/log/placement /var/lib/placement /var/cache/placement
COPY --from=build --link /var/lib/openstack /var/lib/openstack
