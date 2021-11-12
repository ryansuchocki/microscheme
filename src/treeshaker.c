/* ======================= Microscheme =======================
 * Treeshaker
 * (C) 2014-2021 Ryan Suchocki, et al.
 * http://github.com/ryansuchocki/microscheme
 */

#include "common.h"
#include "lexer.h"
#include "parser.h"
#include "scoper.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *currentDefinition = NULL;

int numUsedGlobals = 0, numPurgedGlobals = 0;

extern Environment *globalEnv;

void treeshaker_shakeExpr(AST_expr *expr)
{

    int i;

    switch (expr->type)
    {
        // The simple ones (recursion only):
        case Constant: break;
        case ProcCall:
            // fall through
        case TailCall:
            treeshaker_shakeExpr(expr->proc);
            // fall through
        case Branch:
            // fall through
        case When:
            // fall through
        case Sequence:
            // fall through
        case PrimCall:
            // fall through
        case OtherFundemental:
            // fall through
        case And:
            // fall through
        case Or:
            // fall through
        case Lambda:
            for (i = 0; i < expr->numBody; i++)
            {
                treeshaker_shakeExpr(expr->body[i]);
            }
            break;
        case Assignment: treeshaker_shakeExpr(expr->body[0]); break;

        case Definition: // Nothing to do;
            if (expr->numBody == 1)
            {
                if (globalEnv->realAddress[expr->varRefIndex] >= 0)
                {
                    currentDefinition = expr->variable;
                    expr->type = Assignment;
                    treeshaker_shakeExpr(expr->body[0]);
                    expr->type = Definition;
                    currentDefinition = NULL;
                }
            }

            break;

        case Variable:
            if (expr->varRefType == Global)
                if (!currentDefinition || (strcmp(expr->variable, currentDefinition) != 0))
                    globalEnv->references[expr->varRefIndex] = globalEnv->references[expr->varRefIndex] + 1;

            break;
    }
}

void treeshaker_purge(void)
{
    numUsedGlobals = 0;
    numPurgedGlobals = 0;

    int i;
    for (i = 0; i < globalEnv->numBinds; i++)
    {
        //fprintf(stderr, "<%s> %i\n", globalEnv->binding[i], globalEnv->references[i]);
        if (globalEnv->references[i] > 0)
        {
            globalEnv->realAddress[i] = numUsedGlobals;
            numUsedGlobals++;
            globalEnv->references[i] = 0;
        }
        else
        {
            numPurgedGlobals++;
            globalEnv->realAddress[i] = -1;
            //fprintf(stderr, ">> Aggressive: Global <%s> will be purged.\n", globalEnv->binding[i]);
        }
    }
}
