# Checkpoint-Restore for WASM modules with WAMR

This repository contains a proof-of-concept implementation of a library to
provide checkpoint-restore functionality to WebAssembly modules running on
WAMR.

## Build

The recommended build environment is using our development docker image:

```bash
docker run \
  --rm -it \
  --name iwasmcr-dev \
  -v $(pwd):/workspace \
  --workdir /workspace \
  csegarragonz/wasm-micro-runtime-cr:main \
  bash
```

alternatively, you can also use the `./bin/run_docker.sh` script (and stop
with `./bin/stop_docker.sh`).

Inside the container, you may run:

```bash
# Build iwasm-cr executable
./bin/build.sh [--clean]

# Build WASM apps
./bin/build_wasm.sh
```

## Run the demo

You can run the sample counter app with:

```bash
./build/iwasm-cr --file ./wasm-apps/counter.wasm
```
