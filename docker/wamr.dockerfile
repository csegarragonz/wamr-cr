FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        apt-transport-https \
        apt-utils build-essential \
        autoconf \
        automake \
        autotools-dev \
        ca-certificates \
        ccache \
        curl \
        g++-multilib \
        git \
        gnupg \
        libboost-program-options \
        libgcc-9-dev \
        lib32gcc-9-dev \
        libprotobuf-dev \
        libprotoc-dev \
        libtool \
        lsb-release \
        ninja-build \
        pkg-config \
        python3 \
        python3-pip \
        python3-requests \
        protobuf-compiler \
        software-properties-common \
        tree \
        tzdata \
        unzip \
        valgrind \
        vim \
        wget \
        zip --no-install-recommends \
    && apt clean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Cmake
RUN wget -O /tmp/kitware-archive-latest.asc \
        https://apt.kitware.com/keys/kitware-archive-latest.asc \
    && gpg --no-default-keyring \
        --keyring /tmp/tmp-key.gpg \
        --import /tmp/kitware-archive-latest.asc \
    && gpg --no-default-keyring \
        --keyring /tmp/tmp-key.gpg \
        --export --output /etc/apt/keyrings/kitware-archive-latest.gpg \
    && rm /tmp/tmp-key.gpg \
    && echo \
        "deb [signed-by=/etc/apt/keyrings/kitware-archive-latest.gpg] https://apt.kitware.com/ubuntu/ jammy main" \
        >> /etc/apt/sources.list.d/archive_uri-https_apt_kitware_com_ubuntu_jammy_-jammy.list \
    && apt update \
    && apt install -y cmake

# clang+llvm
ARG LLVM_VERSION=14
RUN cd /tmp && \
    wget --progress=dot:giga https://apt.llvm.org/llvm.sh \
    && chmod a+x ./llvm.sh \
    && ./llvm.sh ${LLVM_VERSION} all

# binaryen
ARG BINARYEN_VERSION=112
WORKDIR /opt
RUN wget -c --progress=dot:giga \
        https://github.com/WebAssembly/binaryen/releases/download/version_${BINARYEN_VERSION}/binaryen-version_${BINARYEN_VERSION}-x86_64-linux.tar.gz \
    && tar xf binaryen-version_${BINARYEN_VERSION}-x86_64-linux.tar.gz \
    && ln -sf /opt/binaryen-version_${BINARYEN_VERSION} /opt/binaryen \
    && rm binaryen-version_${BINARYEN_VERSION}-x86_64-linux.tar.gz

# install wasi-sdk
ARG WASI_SDK_VER=19
RUN wget -c --progress=dot:giga \
        https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_SDK_VER}/wasi-sdk-${WASI_SDK_VER}.0-linux.tar.gz -P /opt \
    && tar xf /opt/wasi-sdk-${WASI_SDK_VER}.0-linux.tar.gz -C /opt \
    && ln -sf /opt/wasi-sdk-${WASI_SDK_VER}.0 /opt/wasi-sdk \
    && rm /opt/wasi-sdk-${WASI_SDK_VER}.0-linux.tar.gz

# install wabt
ARG WABT_VER=1.0.29
RUN wget -c --progress=dot:giga \
        https://github.com/WebAssembly/wabt/releases/download/${WABT_VER}/wabt-${WABT_VER}-ubuntu.tar.gz -P /opt \
    && tar xf /opt/wabt-${WABT_VER}-ubuntu.tar.gz -C /opt \
    && ln -sf /opt/wabt-${WABT_VER} /opt/wabt \
    && rm /opt/wabt-${WABT_VER}-ubuntu.tar.gz

# install bazelisk
ARG BAZELISK_VER=1.12.0
RUN mkdir /opt/bazelisk \
    && wget -c --progress=dot:giga https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VER}/bazelisk-linux-amd64 -P /opt/bazelisk \
    && chmod a+x /opt/bazelisk/bazelisk-linux-amd64 \
    && ln -fs /opt/bazelisk/bazelisk-linux-amd64 /opt/bazelisk/bazel

# Install WAMR and build some targets
# Note: WAMR does not tag code frequently, so we need to use commit hashes
# Hash dates from: 16/03/2023

# Build wamrc
ARG WAMR_VERSION=23e9a356e50f157210c72bd7e19570474409edbd
RUN rm -rf /workspace \
    && mkdir -p /workspace \
    && git clone \
        -b main \
        https://github.com/bytecodealliance/wasm-micro-runtime \
        /workspace \
    && cd /workspace \
    && git checkout ${WAMR_VERSION} \
    && cd wamr-compiler \
    && ./build_llvm.sh \
    && mkdir -p build \
    && cd ./build \
    && cmake .. \
    && cmake --build . \
    && ln -sf /workspace/wamr-compiler/build/wamrc /usr/local/bin/wamrc

# Build iwasm
RUN cd /workspace/product-mini/platforms/linux \
    && mkdir -p build \
    && cd ./build \
    && cmake .. \
    && cmake --build . \
    && ln -sf /workspace/product-mini/platforms/linux/build/iwasm /usr/local/bin/iwasm

# Set up working environmnet
ENV PATH=/usr/local/bin:/opt/wabt/bin:${PATH}
ENV WASI_SDK_PATH=/opt/wasi-sdk
WORKDIR /workspace
