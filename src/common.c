/*	microScheme Common Source File	*/

/* These are low-level memory managent routines used 
   throughout the Microscheme source code.                 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void* tmp = 0;

void* try_malloc (size_t size) {
	tmp = malloc(size);
	if (!tmp) {
		fprintf(stderr, "ERROR 0: Out of memory (malloc)\n");
		exit(1);
	}
	return tmp;
}

void* try_realloc (void *ptr, size_t size) {
	tmp = realloc(ptr, size);
	if (!tmp) {
		fprintf(stderr, "ERROR 0: Out of memory (realloc)\n");
		exit(1);
	}
	return tmp;
}

void try_free(void* ptr) {
	if (ptr != NULL) free(ptr);
}

char* str_clone (char *src) {
	char *new = try_malloc(sizeof(char) * (strlen(src) + 1));
	return strcpy(new, src);
}

char* str_clone_more (char *src, int more) {
	char *new = try_malloc(sizeof(char) * (strlen(src) + 1 + more));
	return strcpy(new, src);
}