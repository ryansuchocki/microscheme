/*	microScheme Scoper Header File	*/

#ifndef _SHAKER_H_GUARD
#define _SHAKER_H_GUARD

	extern void treeshaker_shakeExpr(AST_expr *expr);

	extern void treeshaker_purge(Environment *globalEnv);

	extern int numUsedGlobals;
	extern int numPurgedGlobals;

#endif

