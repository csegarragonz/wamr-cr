# Checkpoint-Restore for WASM modules with WAMR

This repository contains a proof-of-concept implementation of a library to
provide checkpoint-restore functionality to WebAssembly modules running on
WAMR.

## To-Dos

* [ ] Shorter boost installation time
* [ ] Scripts to run/attach to docker container (no docker compose)

## Build

The recommended build environment is using our development docker image:

```bash
docker run \
  --rm -it \
  --name iwasmcr \
  -v $(pwd):/workspace/product-mini/platforms/linux-cr \
  -v $(pwd)/dev/conan2:/root/.conan2 \
  --workdir /workspace/product-mini/platforms/linux-cr \
  csegarragonz/wasm-micro-runtime:main \
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

TODO: demo not working
