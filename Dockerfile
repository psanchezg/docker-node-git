# syntax=docker/dockerfile:1.2

# e.g.: `docker build --rm --build-arg "NODE_VERSION=latest" -f ./Dockerfile .`
# e.g.: `docker build --rm --build-arg "NODE_VERSION=10" -f ./Dockerfile .`

#############################
# Settings Common Variables #
#############################
ARG NODE_VERSION=10

ARG DISTRO=alpine
ARG DISTRO_VER=10.0.0
ARG BUILD_DATE

FROM node:${NODE_VERSION}-${DISTRO}

ENV NODE_VERSION=$NODE_VERSION

ENV BUILD_DATE=$BUILD_DATE

LABEL maintainer="Pablo Sánchez <pablo.sanchez@aranova.es>"

ENV DOCKER_IMAGE=psanchezg/node-git
ENV DOCKER_IMAGE_OS=${DISTRO}
ENV DOCKER_IMAGE_TAG=${DISTRO_VER}

LABEL maintainer="Pablo Sánchez <pablo.sanchez@aranova.es>" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.description="Node ${NODE_VERSION} based on node:${NODE_VERSION}:-${DISTRO} ${DOCKER_IMAGE_TAG}." \
    org.label-schema.docker.cmd="docker run -p 8080:8080 -d ${DOCKER_IMAGE}:${DISTRO_VER}-${DOCKER_IMAGE_OS}${DOCKER_IMAGE_TAG}"

RUN set -x \
    && . /etc/os-release \
    && mkdir -p /var/log/supervisor \
    && case "$ID" in \
        alpine) \
            apk add --no-cache bash git supervisor sudo \
            ;; \
        debian) \
            apt-get update \
            && apt-get -yq install bash git supervisor sudo \
            && apt-get -yq clean \
            && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
            ;; \
    esac \
    # show installed application versions
    && git --version && bash --version && npm -v && node -v && yarn -v

# Add Scripts
COPY conf /etc
COPY scripts/start.sh /start.sh
COPY scripts/pull /usr/bin/pull
COPY scripts/push /usr/bin/push
RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push && chmod 755 /start.sh

RUN mkdir -p /etc/sudoers.d \
        && echo "node ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/node \
        && chmod 0440 /etc/sudoers.d/node

WORKDIR "/var/www/app"

CMD ["/start.sh"]