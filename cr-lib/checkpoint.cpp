// TODO: investigate why .h and not .hpp
#include "cr-lib/exec_env.pb.h"
#include "checkpoint.hpp"
#include "file_utils.hpp"

#include <stdio.h>

namespace iwasmcr {

// Dump the contents in the exec_env variable to a protocol buffer, and
// serialise it to a file. Finally, terminate the WASM execution gracefully.
void checkpoint(wasm_exec_env_t exec_env)
{
    auto msg = std::make_shared<iwasmcr::WASMExecEnv>();
    msg->mutable_cur_frame()->set_foo("hello world!");

    std::string serialised;
    if (!msg->SerializeToString(&serialised)) {
        std::cerr << "Error serialising protobuf to string!" << std::endl;
        throw std::runtime_error("Error serialising");
    }

    iwasmcr::utils::dump_to_file(TEST_FILE_NAME, serialised);

    std::cout << "Successfully dumped checkpoint to file: " << TEST_FILE_NAME << std::endl;
}
}
