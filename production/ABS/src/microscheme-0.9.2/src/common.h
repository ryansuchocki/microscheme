/*	microScheme Common Header File	*/

#ifndef _COMMON_H_GUARD
#define _COMMON_H_GUARD

// Shared function declarations
	extern void* try_malloc (size_t size);
	extern void* try_realloc (void *ptr, size_t size);
	extern void try_free(void* ptr);
	extern char* str_clone (char *src);
	extern char* str_clone_more (char *src, int more);

#endif