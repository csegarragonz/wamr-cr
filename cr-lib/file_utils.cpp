#include "file_utils.hpp"

// TODO - include 3rd-party packages
// #include <format>
#include <fstream>
#include <iostream>
#include <span>
#include <sstream>
#include <sys/stat.h>
#include <vector>

namespace iwasmcr::utils {

void dump_to_file(const std::string& path, const std::string& buffer)
{
    std::ofstream outfile;
    outfile.open(path, std::ios::out | std::ios::binary);

    if (!outfile.is_open()) {
        throw std::runtime_error("Could not write to file " + path);
    }

    outfile.write(buffer.data(), buffer.size());
    outfile.close();
}

std::string load_from_file(const std::string& path)
{
    std::ifstream stream(path);
    std::stringstream buffer;
    buffer << stream.rdbuf();
    buffer.flush();

    return buffer.str();
}

std::vector<uint8_t> load_bytes_from_file(const std::string& path)
{
    // Open file
    FILE* fp = fopen(path.c_str(), "rb");
    if (fp == nullptr) {
        throw std::runtime_error("error");
    }

    // Work-out file size
    struct stat statbuf;
    int staterr = fstat(fileno(fp), &statbuf);
    if (staterr < 0) {
        throw std::runtime_error("Couldn't stat file " + path);
    }
    size_t file_size = statbuf.st_size;
    std::vector<uint8_t> result;
    result.resize(file_size);

    // Load bytes to buffer
    size_t num_read = fread(result.data(), sizeof(uint8_t), file_size, fp);
    if (num_read != file_size) {
        throw std::runtime_error("Read less bytes than expected");
    }

    fclose(fp);
    return result;
}
}
