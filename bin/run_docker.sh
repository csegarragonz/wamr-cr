#!/bin/bash

set -e

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" >/dev/null 2>&1 && pwd )"
PROJ_ROOT="${THIS_DIR}/.."

CTR_NAME=iwasmcr-dev

pushd ${PROJ_ROOT} >> /dev/null

if [[ ! "$(docker ps -a -q -f name=${CTR_NAME})" ]]; then
    if [[ "$(docker ps -aq -f status=exited -f name=${CTR_NAME})" ]]; then
        docker rm ${CTR_NAME}
    fi

    docker run \
      -d \
      --name ${CTR_NAME} \
      -v $(pwd):/workspace/product-mini/platforms/linux-cr \
      --workdir /workspace/product-mini/platforms/linux-cr \
      csegarragonz/wasm-micro-runtime:main \
      bash
fi

docker exec -it ${CTR_NAME} bash

popd >> /dev/null
