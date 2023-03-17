
/*
 * Copyright (C) 2019 Intel Corporation.  All rights reserved.
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
 */

#include "wasm_export.h"
#include "bh_read_file.h"
#include "bh_getopt.h"
#include "cr-lib/checkpoint.hpp"
#include "cr-lib/file_utils.hpp"
#include "cr-lib/restore.hpp"

// TODO - install libboost w/ CMake
#include <boost/program_options.hpp>
#include <iostream>
#include <unistd.h>

int __checkpoint(wasm_exec_env_t exec_env)
{
    std::cout << "__checkpoint: hello from host!" << std::endl;

    iwasmcr::checkpoint(exec_env);

    sleep(2);

    iwasmcr::restore(exec_env);

    return 0;
}

namespace po = boost::program_options;

po::variables_map parseCmdLine(int argc, char* argv[])
{
    // Define command line arguments
    po::options_description desc("Allowed options");
    desc.add_options()(
      "file", po::value<std::string>(), "WebAssembly function to run")(
      "restore", po::value<std::string>(), "Checkpoint image to restore from");

    po::positional_options_description p;
    p.add("func", 1);

    // Parse command line arguments
    po::variables_map vm;
    po::store(
      po::command_line_parser(argc, argv).options(desc).positional(p).run(),
      vm);
    po::notify(vm);

    return vm;
}

int main(int argc, char* argv[])
{
    // ------------------
    // Command-Line Argument Parsing
    // ------------------

    auto vm = parseCmdLine(argc, argv);
    std::string func_path = vm["file"].as<std::string>();
    std::vector<uint8_t> func_bytes = iwasmcr::utils::load_bytes_from_file(func_path);
    bool must_restore = vm.find("restore") != vm.end();
    std::vector<uint8_t> cp_img_bytes;
    if (must_restore) {
        cp_img_bytes = iwasmcr::utils::load_bytes_from_file(vm["restore"].as<std::string>());
    }

    // ------------------
    // Initialise WAMR runtime
    // ------------------

    static char global_heap_buf[512 * 1024];

    RuntimeInitArgs init_args;
    memset(&init_args, 0, sizeof(RuntimeInitArgs));

    init_args.mem_alloc_type = Alloc_With_Pool;
    init_args.mem_alloc_option.pool.heap_buf = global_heap_buf;
    init_args.mem_alloc_option.pool.heap_size = sizeof(global_heap_buf);

    static NativeSymbol native_symbols[] = {
        {"__checkpoint", (void*)__checkpoint, "()i", nullptr}
    };

    // Native symbols need below registration phase
    init_args.n_native_symbols = sizeof(native_symbols) / sizeof(NativeSymbol);
    init_args.native_module_name = "env";
    init_args.native_symbols = native_symbols;

    if (!wasm_runtime_full_init(&init_args)) {
        printf("Init runtime environment failed.\n");
        return -1;
    }

    // ------------------
    // Instantiate WASM module and call function
    // ------------------

    // Load WASM module
    std::string error_buffer(256, '\0');
    auto module_deleter = [&](wasm_module_t mod) {
        std::cout << "Module being deleted" << std::endl;
        if (mod != nullptr) {
            wasm_runtime_unload(mod);
        }
    };
    std::unique_ptr<WASMModuleCommon, decltype(module_deleter)> module(
        wasm_runtime_load(func_bytes.data(),
                          func_bytes.size(),
                          error_buffer.data(),
                          error_buffer.size()),
        module_deleter
    );
    if (module == nullptr) {
        std::cerr << "Error loading WASM module: " << error_buffer << std::endl;
        throw std::runtime_error("Error loading WASM module");
    }

    // Create module instance
    uint32_t stack_size = 8092;
    uint32_t heap_size = 8092;
    auto instance_deleter = [&](wasm_module_inst_t inst) {
        std::cout << "Instance being deleted" << std::endl;
        if (inst != nullptr) {
            wasm_runtime_deinstantiate(inst);
        }
    };
    std::unique_ptr<WASMModuleInstanceCommon, decltype(instance_deleter)> module_inst(
        wasm_runtime_instantiate(module.get(),
                                 stack_size,
                                 heap_size,
                                 error_buffer.data(),
                                 error_buffer.size()),
        instance_deleter
    );
    if (module_inst == nullptr) {
        std::cerr << "Error instantiating the WASM module: " << error_buffer << std::endl;
        throw std::runtime_error("Error instantiating WASM module");
    }

    // Call function at the right entrypoint depending on wether we are
    // restoring from a checkpoint or not
    bool success = false;
    if (must_restore) {
        // TODO: apply things on the running instance?
        // TODO: what do we call when we restore?
    } else {
        success = wasm_application_execute_main(module_inst.get(), 0, NULL);
    }
    if (!success) {
        std::cerr << "Error executing " << (must_restore ? "restored" : "main") << " function" << std::endl;
        throw std::runtime_error("Error executing function");
    }

    // TODO: calling this here yields a number of warnings
    // wasm_runtime_destroy();

    return 0;
}
