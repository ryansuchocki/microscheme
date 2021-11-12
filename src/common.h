/* ======================= Microscheme =======================
 * Common helper module
 * (C) 2014-2021 Ryan Suchocki, et al.
 * http://github.com/ryansuchocki/microscheme
 */

#ifndef _COMMON_H_GUARD
#define _COMMON_H_GUARD

#include <stdlib.h>

// Shared function declarations
extern void *try_malloc(size_t size) __attribute__((returns_nonnull));
;
extern void *try_realloc(void *ptr, size_t size) __attribute__((returns_nonnull));
;
extern void try_free(void *ptr);
extern char *str_clone(char *src);
extern char *str_clone_more(char *src, int more);

#endif