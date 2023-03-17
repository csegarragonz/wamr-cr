#!/bin/bash

set -e

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" >/dev/null 2>&1 && pwd )"
PROJ_ROOT="${THIS_DIR}/.."

pushd ${PROJ_ROOT} >> /dev/null

CC=/opt/wasi-sdk/bin/clang
SYSROOT=/opt/wasi-sdk/share/wasi-sysroot

for wasm_file in ${PROJ_ROOT}/wasm-apps/*.c; do
    c_file=$(basename -- ${wasm_file})
    ${CC} \
        --sysroot=${SYSROOT} \
        -Wl,--allow-undefined \
        "${PROJ_ROOT}/wasm-apps/${c_file}" \
        -o "${PROJ_ROOT}/wasm-apps/${c_file%.c}.wasm"
done


popd >> /dev/null
