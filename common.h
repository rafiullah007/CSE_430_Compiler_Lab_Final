#ifndef COMMON_H
#define COMMON_H

#include <stdlib.h>
#include <string.h>

static inline char *xstrdup(const char *s) {
    size_t len = strlen(s) + 1;
    char *copy = (char *)malloc(len);
    if (copy == NULL) {
        return NULL;
    }
    memcpy(copy, s, len);
    return copy;
}

#endif
