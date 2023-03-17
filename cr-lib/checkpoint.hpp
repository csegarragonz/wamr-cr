#pragma once

#include "wasm_export.h"

namespace iwasmcr {

/* Dump wasm_exec_env_t contents to a file.
 *
 * To-Do:
 * - Support different 'backends' to dump to
 */
void checkpoint(wasm_exec_env_t exec_env);
}
