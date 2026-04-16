# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:2024.1@sha256:cdba272e8267b16b4ff11182f13d1ecfe6c952ae9a6f748381399031da52fa4b AS build
RUN --mount=type=bind,from=placement,source=/,target=/src/placement,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/placement
EOF

FROM ghcr.io/vexxhost/python-base:2024.1@sha256:3f25f319b357136cd82eced18a562d33b893c42516eccb3cae920f560f15eb08
RUN \
    groupadd -g 42424 placement && \
    useradd -u 42424 -g 42424 -M -d /var/lib/placement -s /usr/sbin/nologin -c "Placement User" placement && \
    mkdir -p /etc/placement /var/log/placement /var/lib/placement /var/cache/placement && \
    chown -Rv placement:placement /etc/placement /var/log/placement /var/lib/placement /var/cache/placement
COPY --from=build --link /var/lib/openstack /var/lib/openstack
