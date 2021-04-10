#!/bin/bash

set -ex

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# ENV vars
BUILD_TAG=${BUILD_TAG:-latest}
DOCKER_IMAGE="npm_redis:${BUILD_TAG}"



# Build image
docker build \
    -t ${DOCKER_IMAGE} \
    ${PWD}
