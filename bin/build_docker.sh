#!/bin/bash

set -e

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" >/dev/null 2>&1 && pwd )"
PROJ_ROOT="${THIS_DIR}/.."
DOCKER_DIR="${PROJ_ROOT}/docker"

pushd ${PROJ_ROOT} >> /dev/null

docker buildx build -t csegarragonz/wasm-micro-runtime-base:main - < ${DOCKER_DIR}/wamr_base.dockerfile
docker buildx build -t csegarragonz/wasm-micro-runtime-cr:main - < ${DOCKER_DIR}/wamr_cr.dockerfile

# Only build workon conditionally
if [[ "$1" == "--build-workon" ]]; then
    docker buildx build -t csegarragonz/wasm-micro-runtime-cr-workon:main - < ${DOCKER_DIR}/csg_workon_wamr.dockerfile
fi

popd >> /dev/null
