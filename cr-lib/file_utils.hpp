#pragma once

#include <cstdint>
#include <string>
#include <vector>

#define TEST_FILE_NAME "./checkpoints/counter.img"

namespace iwasmcr::utils {

// int dump_to_file(const char* file_name, uint8_t* buffer, std::size_t buffer_size);
void dump_to_file(const std::string& path, const std::string& buffer);

std::string load_from_file(const std::string& path);

std::vector<uint8_t> load_bytes_from_file(const std::string& path);
}
