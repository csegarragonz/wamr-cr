#pragma once

#include "wasm_export.h"

namespace iwasmcr {

/* Restore from checkpointed `exec_env`
 *
 * To-Do:
 * - Support different 'backends' to dump to
 */
void restore(wasm_exec_env_t exec_env);
}
