#!/bin/bash

# Modified version by Mian-Heng Shan (@samynhn), 2024

# Copyright (c) 2024 Mian-Heng Shan (@samynhn)
# Copyright (c) 2023 ACAL, National Cheng Kung University
# Copyright (c) 2022 Playlab, National Cheng Kung University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e

cd "$(dirname "$0")"

CURRENT_DIR_NAME="$(basename "$(cd .. && pwd)")"
IMAGE_NAME="${CURRENT_DIR_NAME,,}-image"
CONTAINER_NAME="${CURRENT_DIR_NAME,,}-container"
PROJECT_NAME="${CURRENT_DIR_NAME}"
USERNAME="$(id -un)"

VOLUME_PROJECTS_DIR="$(cd .. && pwd)/"
VOLUME_SSH_DIR="${PWD}/temp/.ssh/"
VOLUME_VSCODESERVER_DIR="${PWD}/temp/.vscode-server/"

usage_message() {
    cat <<EOF
    
    # Copyright (c) 2024 Mian-Heng Shan (@samynhn)
    # Copyright (c) 2023 ACAL, National Cheng Kung University
    # Copyright (c) 2022 Playlab, National Cheng Kung University
    # All rights reserved.  

    This is a general Docker script for building and running the image and container.
    Modified from the ACAL Playlab, National Cheng Kung University.
    And extended by Mian-Heng Shan (@samynhn), 2024.
    You can execute this script with the following options.

    start     : 🏗️  build and enter the container
    stop      : ⏹️  stop and exit the container
    restart   : 🔄  stop and start the container
    remove    : 🗑️  remove the docker image and container
    rebuild   : 🔨  remove and build a new image and container

EOF
}

start_docker_container() {
    #NOTE: build image if not exist
    if [[ "$(docker images -q ${IMAGE_NAME})" == "" ]]; then
        docker build \
            --build-arg UID="$(id -u)" \
            --build-arg GID="$(id -g)" \
            --build-arg USERNAME="${USERNAME}" \
            --build-arg PROJNAME="${PROJECT_NAME}" \
            --build-arg ARCH="$(uname -m)" \
            -t ${IMAGE_NAME} . ||
            { echo "❌ Error: failed to build docker image" && exit 1; }
    fi
    #NOTE: create volume if not exist
    [[ -d ${VOLUME_SSH_DIR} ]] || mkdir -p "${VOLUME_SSH_DIR}"
    [[ -d ${VOLUME_VSCODESERVER_DIR} ]] || mkdir -p "${VOLUME_VSCODESERVER_DIR}"
    [[ -d ${VOLUME_PROJECTS_DIR} ]] || mkdir -p "${VOLUME_PROJECTS_DIR}"

    #NOTE: create container if not exist
    if [[ "$(docker ps -a | grep ${CONTAINER_NAME})" == "" ]]; then
        docker run -d \
            --gpus all \
            -v "$([[ ${OSTYPE} == "msys" ]] && echo "/${VOLUME_PROJECTS_DIR}" || echo "${VOLUME_PROJECTS_DIR}")":"/home/${USERNAME}/${PROJECT_NAME}/" \
            -v "$([[ ${OSTYPE} == "msys" ]] && echo "/${VOLUME_SSH_DIR}" || echo "${VOLUME_SSH_DIR}")":"/home/${USERNAME}/.ssh/" \
            -v "$([[ ${OSTYPE} == "msys" ]] && echo "/${VOLUME_VSCODESERVER_DIR}" || echo "${VOLUME_VSCODESERVER_DIR}")":"/home/${USERNAME}/.vscode-server/" \
            --hostname "$(echo ${CONTAINER_NAME} | tr '[:lower:]' '[:upper:]')" \
            --name ${CONTAINER_NAME} \
            ${IMAGE_NAME} ||
            { echo "❌ Error: failed to run docker container" && exit 1; }
    fi
    #NOTE: start container if not running
    if [[ "$(docker ps -a | grep ${CONTAINER_NAME})" != "" ]]; then
        docker start ${CONTAINER_NAME} ||
            { echo "❌ Error: failed to start docker container" && exit 1; }
    fi


    #NOTE: enter container
    case ${OSTYPE} in
    msys)
        winpty docker exec -it ${CONTAINER_NAME} bash
        ;;
    *)
        docker exec -it ${CONTAINER_NAME} bash
        ;;
    esac

    clear
}

stop_docker_container() {
    if [[ "$(docker ps -a | grep ${CONTAINER_NAME})" != "" ]]; then
        docker stop ${CONTAINER_NAME} ||
            { echo "❌ Error: failed to stop docker container" && exit 1; }
    fi
}

remove_docker_container() {
    if [[ "$(docker ps -a | grep ${CONTAINER_NAME})" != "" ]]; then
        docker container rm -f ${CONTAINER_NAME} ||
            { echo "❌ Error: failed to remove docker container" && exit 1; }
    fi
}

remove_docker_image() {
    if [[ "$(docker images -q ${IMAGE_NAME})" != "" ]]; then
        docker rmi ${IMAGE_NAME} ||
            { echo "❌ Error: failed to remove docker image" && exit 1; }
    fi
}

remove_build_cache() {
    docker builder prune -a -f
}

confirm_action() {
    echo "⚠️  Are you sure you want to $1? (y/n)"
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            echo "❌ Operation aborted by user."
            exit 0
            ;;
    esac
}

export DOCKER_SCAN_SUGGEST=false

[[ $(
    docker ps >/dev/null 2>&1
    echo $?
) != 0 ]] && echo "❌ Error: please install and start Docker Engine first!!!" && exit 1

case $1 in
start)
    start_docker_container
    ;;
stop)
    stop_docker_container
    ;;
restart)
    stop_docker_container
    start_docker_container
    ;;
remove)
    confirm_action "remove both the container and the image"
    remove_docker_container
    remove_docker_image
    remove_build_cache
    ;;
rebuild)
    confirm_action "rebuild the image and container"
    remove_docker_container
    remove_docker_image
    remove_build_cache
    start_docker_container
    ;;
*)
    usage_message
    ;;
esac
