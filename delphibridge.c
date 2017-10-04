
#include "yaml_private.h"

/*
 * Declarations.
 */

extern void
yaml_delphibridge_getsizes(size_t* yaml_parser_size, size_t* yaml_emitter_size) {
    *yaml_parser_size = sizeof(yaml_parser_t);
    *yaml_emitter_size = sizeof(yaml_emitter_t);
}

#define FLUSH(emitter)                                                          \
    ((emitter->buffer.pointer+5 < emitter->buffer.end)                          \
     || yaml_emitter_flush(emitter))

#define PUT(emitter,value)                                                      \
    (FLUSH(emitter)                                                             \
     && (*(emitter->buffer.pointer++) = (yaml_char_t)(value),                   \
         emitter->column ++,                                                    \
         1))

#define PUT_BREAK(emitter)                                                      \
    (FLUSH(emitter)                                                             \
     && ((emitter->line_break == YAML_CR_BREAK ?                                \
             (*(emitter->buffer.pointer++) = (yaml_char_t) '\r') :              \
          emitter->line_break == YAML_LN_BREAK ?                                \
             (*(emitter->buffer.pointer++) = (yaml_char_t) '\n') :              \
          emitter->line_break == YAML_CRLN_BREAK ?                              \
             (*(emitter->buffer.pointer++) = (yaml_char_t) '\r',                \
              *(emitter->buffer.pointer++) = (yaml_char_t) '\n') : 0),          \
         emitter->column = 0,                                                   \
         emitter->line ++,                                                      \
         1))

extern int
yaml_delphibridge_put_break(yaml_emitter_t *emitter) {
    return PUT_BREAK(emitter);
}

extern int
yaml_delphibridge_put_whitespace(yaml_emitter_t *emitter, int indent) {
    while (emitter->column < indent) {
        if (!PUT(emitter, ' ')) return 0;
    }
    return 1;
}
