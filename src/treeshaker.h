/* ======================= Microscheme =======================
 * Treeshaker
 * (C) 2014-2021 Ryan Suchocki, et al.
 * http://github.com/ryansuchocki/microscheme
 */

#ifndef _SHAKER_H_GUARD
#define _SHAKER_H_GUARD

extern void treeshaker_shakeExpr(AST_expr *expr);

extern void treeshaker_purge(void);

extern int numUsedGlobals;
extern int numPurgedGlobals;

#endif
