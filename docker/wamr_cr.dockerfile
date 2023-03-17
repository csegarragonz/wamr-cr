FROM csegarragonz/wasm-micro-runtime-base:main

# Install APT dependencies to build WAMR-CR library
RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        libboost-program-options-dev

# Build wamrc, iwasm, and iwasm-cr
RUN rm -rf /workspace \
    && mkdir -p /workspace \
    && git clone \
        -b main \
        https://github.com/csegarragonz/wamr-cr.git \
        /workspace \
    && cd /workspace \
    && git submodule update --init \
    && cd ./wasm-micro-runtime/wamr-compiler \
    && ./build_llvm.sh \
    && mkdir -p build \
    && cd ./build \
    && cmake .. \
    && cmake --build . \
    && ln -sf /opt/wasm-micro-runtime/wamr-compiler/build/wamrc /usr/local/bin/wamrc \
    && cd /workspace/wasm-micro-runtime/product-mini/platforms/linux \
    && mkdir -p build \
    && cd ./build \
    && cmake .. \
    && cmake --build . \
    && ln -sf /opt/wasm-micro-runtime/product-mini/platforms/linux/build/iwasm /usr/local/bin/iwasm

ENV TERM xterm-256color
WORKDIR /workspace
SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash", "-l"]
