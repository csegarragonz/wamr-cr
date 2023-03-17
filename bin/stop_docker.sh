#!/bin/bash

set -e

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" >/dev/null 2>&1 && pwd )"
PROJ_ROOT="${THIS_DIR}/.."

CTR_NAME=iwasmcr-dev

pushd ${PROJ_ROOT} >> /dev/null

docker rm -f ${CTR_NAME}

popd >> /dev/null
