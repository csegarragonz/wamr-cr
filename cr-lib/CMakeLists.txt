# --------------------
# Protobuf code generation
# --------------------

function(protobuf_generate_cpp proto_file src_file hdr_file)
    add_custom_command(
        OUTPUT ${src_file} ${hdr_file}
        COMMAND /usr/bin/protoc
        ARGS -I${CMAKE_CURRENT_LIST_DIR} ${proto_file} --cpp_out=${CMAKE_BINARY_DIR}/cr-lib
    )
endfunction()

set(PB_SRC exec_env.pb.cc)
set(PB_HDR exec_env.pb.h)
protobuf_generate_cpp(exec_env.proto ${PB_SRC} ${PB_HDR})

# --------------------
# C/R Library
# --------------------

add_library(cr-lib
    checkpoint.cpp
    file_utils.cpp
    restore.cpp
    ${PB_SRC}
    ${PB_HDR}
)
target_include_directories(cr-lib PUBLIC ${CMAKE_BINARY_DIR})
target_link_libraries(cr-lib PUBLIC
    protobuf
)
