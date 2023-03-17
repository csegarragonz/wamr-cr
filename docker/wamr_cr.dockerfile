FROM csegarragonz/wasm-micro-runtime:main

# Install APT dependencies to build WAMR-CR library
RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        libboost-program-options-dev

RUN rm -rf /workspace \
    && mkdir -p /workspace \
    && git clone \
        -b main \
        https://github.com/csegarragonz/wamr-cr.git \
        /workspace \
    && cd /workspace \
    && git submodule update --init \
    && ./bin/build.sh --clean

ENV TERM xterm-256color
WORKDIR /workspace
SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash", "-l"]
