# syntax=docker/dockerfile:1.2

# e.g.: `docker build --rm --build-arg "NODE_VERSION=latest" -f ./Dockerfile .`
# e.g.: `docker build --rm --build-arg "NODE_VERSION=10" -f ./Dockerfile .`
ARG NODE_VERSION
ARG DISTRO=alpine
ARG DISTRO_VER=10.0.0

LABEL maintainer="Pablo Sánchez <pablo.sanchez@aranova.es>"

ENV DOCKER_IMAGE=psanchezg/node-git
ENV DOCKER_IMAGE_OS=${DISTRO}
ENV DOCKER_IMAGE_TAG=${DISTRO_VER}

FROM node:${NODE_VERSION}:-${DISTRO}

RUN set -x \
    && . /etc/os-release \
    && case "$ID" in \
        alpine) \
            apk add --no-cache bash git \
            ;; \
        debian) \
            apt-get update \
            && apt-get -yq install bash git \
            && apt-get -yq clean \
            && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
            ;; \
    esac \
    # install yarn, if needed (only applies to older versions, like 6 or 7)
    && yarn bin || ( npm install --global yarn && npm cache clean ) \
    # show installed application versions
    && git --version && bash --version && npm -v && node -v && yarn -v