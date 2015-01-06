/*	microScheme Code Generator Header File	*/

#ifndef _CODEGEN_H_GUARD
#define _CODEGEN_H_GUARD

// Shared function declarations

	extern void codegen_emit(AST_expr *expr, int parent_numArgs, FILE *outputFile);
	extern void codegen_emitPreamble(FILE *outputFile/*, int numUsedGlobals*/) ;
	extern void codegen_emitPostamble(FILE *outputFile) ;
	extern void codegen_emitModelHeader(char *model, FILE *outputFile) ;


#endif