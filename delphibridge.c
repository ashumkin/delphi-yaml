
#include "yaml_private.h"

/*
 * Declarations.
 */

extern void
yaml_delphibridge_getsizes(size_t* yaml_parser_size, size_t* yaml_emitter_size) {
    *yaml_parser_size = sizeof(yaml_parser_t);
    *yaml_emitter_size = sizeof(yaml_emitter_t);
}
