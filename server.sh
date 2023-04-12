#!/bin/bash

set -e

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# ENV vars
BUILD_TAG=${BUILD_TAG:-latest}
BACKUP_PATH=${BACKUP_PATH:-"${PWD}/.backup"}

REDIS_NAME="redis"
REDIS_IMAGE="npm_${REDIS_NAME}:${BUILD_TAG}"
REDIS_HOME="${PWD}/${REDIS_NAME}"

VERDACCIO_NAME="verdaccio"
VERDACCIO_IMAGE="npm_${VERDACCIO_NAME}:${BUILD_TAG}"
VERDACCIO_HOME="${PWD}/${VERDACCIO_NAME}"


function help() {
    echo "HELP"
    echo "Open ./server.sh and try to understand it. I'm too lazy to fill here."
}

function init() {

    # Setup Backup path
    mkdir -p ${BACKUP_PATH}/redis/data

    mkdir -p ${BACKUP_PATH}/verdaccio
    mkdir -p ${BACKUP_PATH}/verdaccio/plugins
    mkdir -p ${BACKUP_PATH}/verdaccio/storage
    touch ${BACKUP_PATH}/verdaccio/storage/htpasswd

    chown -R 10001:65533 "${BACKUP_PATH}/verdaccio"
}

function create_services() {

    # Create the services
    ${REDIS_HOME}/build.sh
    ${VERDACCIO_HOME}/build.sh
}

function start_services() {

    # Start the services
    docker run -d --rm --name ${REDIS_NAME} \
        -p 6379:6379 \
        -v ${REDIS_HOME}/conf/redis.conf:/usr/local/etc/redis/redis.conf \
        -v ${BACKUP_PATH}/redis/data:/data \
        ${REDIS_IMAGE}

    docker run -d --rm --name ${VERDACCIO_NAME} \
        -p 4873:4873 \
        --link ${REDIS_NAME} \
        -v ${VERDACCIO_HOME}/conf:/verdaccio/conf \
        -v ${BACKUP_PATH}/verdaccio/storage:/verdaccio/storage \
        -v ${BACKUP_PATH}/verdaccio/plugins:/verdaccio/plugins \
        ${VERDACCIO_IMAGE}
}

function stop_services() {

    # Stop the services
    docker stop ${VERDACCIO_NAME} || true
    docker stop ${REDIS_NAME} || true
}

function logs_services() {

    # Show the services logs
    docker logs -f ${VERDACCIO_NAME}
}

function nuke_backup() {
    rm -rf ${BACKUP_PATH}
}

CMD=$1

case ${CMD} in
    --init)
        init
        ;;
    --create)
        create_services
        ;;
    --start)
        start_services
        ;;
    --stop)
        stop_services
        ;;
    --logs)
        logs_services
        ;;
    --nuke)
        nuke_backup
        ;;
    --help)
        help
        ;;
    *)
        echo "Invalid Command"
        help
        ;;
esac
