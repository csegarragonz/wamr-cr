#include "cr-lib/exec_env.pb.h"
#include "restore.hpp"
#include "file_utils.hpp"

#include <stdio.h>

namespace iwasmcr {

void restore(wasm_exec_env_t exec_env)
{
    std::string serialised = iwasmcr::utils::load_from_file(TEST_FILE_NAME);
    auto msg = std::make_shared<iwasmcr::WASMExecEnv>();
    if (!msg->ParseFromString(serialised)) {
        std::cerr << "Error deserialising from string!" << std::endl;
        throw std::runtime_error("Error deserialising from string");
    }

    std::cout << "This is the deserialised string: " << msg->cur_frame().foo() << std::endl;
}
}
