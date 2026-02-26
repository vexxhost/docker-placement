# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:zed@sha256:d591a9bc683291d41bee89a465f8f96723e3c240e9bc73d0d33f6f23ea0ef1d7 AS build
RUN --mount=type=bind,from=placement,source=/,target=/src/placement,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/placement
EOF

FROM ghcr.io/vexxhost/python-base:zed@sha256:43e13657031dc049e919108abdb5e70dbff13d31aef7f297bc45bdadf9330862
RUN \
    groupadd -g 42424 placement && \
    useradd -u 42424 -g 42424 -M -d /var/lib/placement -s /usr/sbin/nologin -c "Placement User" placement && \
    mkdir -p /etc/placement /var/log/placement /var/lib/placement /var/cache/placement && \
    chown -Rv placement:placement /etc/placement /var/log/placement /var/lib/placement /var/cache/placement
COPY --from=build --link /var/lib/openstack /var/lib/openstack
