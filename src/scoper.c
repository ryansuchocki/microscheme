/*	microScheme Scoper	*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "lexer.h"
#include "parser.h"
#include "scoper.h"
#include "common.h"

Environment *currentEnvironment;
Environment *currentClosureEnvironment;

void scoper_initEnv(Environment *env) {
	env->binding = NULL;
	env->lexicalAddrV = NULL;
	env->lexicalAddrH = NULL;
	env->references = NULL;
	env->realAddress = NULL;
	env->numBinds = 0;
	env->enclosing = NULL;
}

int getBindingIndex(char *variable, Environment *env) {
	int i;
	for (i=0; i< env->numBinds; i++) {
		if (strcmp(env->binding[i], variable) == 0)
			return i;
	}
	return -1;
}

AST_expr *scoper_scopeExpr(AST_expr *expr) {
	Environment *innerEnvironment, *tmpEnv, *tmpClosEnv, *last;
	
	int i, j, depth;
	
	switch(expr->type) {
		// The simple ones (recursion only):
		case Constant: return expr;
		case ProcCall:
		case TailCall: expr->proc = scoper_scopeExpr(expr->proc); 
		case Branch: 	
		case Sequence: 	
		case PrimCall: 	
		case And: 		
		case Or: 		for (i=0; i<expr->numBody; i++) {expr->body[i] = scoper_scopeExpr(expr->body[i]);} return expr;
		
		// Environment-altering expressions:
		case Definition:

			if (getBindingIndex(expr->variable, currentEnvironment) < 0) {
				if (currentEnvironment->numBinds == 0) {
					currentEnvironment->binding = (char**) try_malloc(sizeof(char*));
					currentEnvironment->references = (int*) try_malloc(sizeof(int));
				} else {
					currentEnvironment->binding = (char**) try_realloc(currentEnvironment->binding, sizeof(char*) * (currentEnvironment->numBinds+1));
					currentEnvironment->references = (int*) try_realloc(currentEnvironment->references, sizeof(int) * (currentEnvironment->numBinds+1));
				}

				currentEnvironment->binding[currentEnvironment->numBinds] = str_clone(expr->variable);
				currentEnvironment->references[currentEnvironment->numBinds] = 0;

				currentEnvironment->numBinds++;
			}

			if (expr->numBody == 1) {

				expr->type = Assignment;
					AST_expr *result = scoper_scopeExpr(expr);
				expr->type = Definition;

				return result;
			} else {
				return expr;
			}
			

		case Lambda:
			innerEnvironment = try_malloc(sizeof(Environment));
			scoper_initEnv(innerEnvironment);
			innerEnvironment->enclosing = currentEnvironment;
			innerEnvironment->numBinds = expr->numFormals;

			innerEnvironment->binding = try_malloc(sizeof(char*) * expr->numFormals);
			for (i=0; i<expr->numFormals; i++) {innerEnvironment->binding[i] = str_clone(expr->formal[i]); }

			innerEnvironment->references = try_malloc(sizeof(int) * expr->numFormals);
			for (i=0; i<expr->numFormals; i++) {innerEnvironment->references[i] = 0; }

			// switch environments
			currentEnvironment = innerEnvironment;

			expr->closure = try_malloc(sizeof(Environment));
			scoper_initEnv(expr->closure);
			expr->closure->enclosing = currentClosureEnvironment;

			currentClosureEnvironment = expr->closure;

			// scope the body
			for (i=0; i<expr->numBody; i++) {
				expr->body[i] = scoper_scopeExpr(expr->body[i]);
			}

			// restore the environment
			currentEnvironment = innerEnvironment->enclosing;
			currentClosureEnvironment = currentClosureEnvironment->enclosing;
			freeEnvironment(innerEnvironment);

			return expr;

		// Environment-dependant expressions:
		case Assignment:
			expr->body[0] = scoper_scopeExpr(expr->body[0]);

			// IMPORTANT: No break here, so assignment falls through to var case:
		
		case Variable:
			tmpEnv = currentEnvironment;
			tmpClosEnv = currentClosureEnvironment;
			depth = 0;

			do {
				if ((i = getBindingIndex(expr->variable, tmpEnv)) >= 0) {

					//DEBUG printf("IN IMMEDIATE SCOPE %s\n", expr->variable);

					if (tmpEnv->enclosing == NULL) {
						expr->varRefType = Global;

					} else if (tmpEnv == currentEnvironment) {
						expr->varRefType = Local;
					} else {
						expr->varRefType = Free;
						expr->varRefHop = depth;

						tmpClosEnv = last;

						if ((j = getBindingIndex(expr->variable, tmpClosEnv)) < 0) {
							if (tmpClosEnv->numBinds == 0) {
								tmpClosEnv->binding = try_malloc(sizeof(char*));
								tmpClosEnv->lexicalAddrV = try_malloc(sizeof(int));
								tmpClosEnv->lexicalAddrH = try_malloc(sizeof(int));
							} else {
								tmpClosEnv->binding = try_realloc(tmpClosEnv->binding, sizeof(char*) * (tmpClosEnv->numBinds+1));
								tmpClosEnv->lexicalAddrV = try_realloc(tmpClosEnv->lexicalAddrV, sizeof(int) * (tmpClosEnv->numBinds+1));
								tmpClosEnv->lexicalAddrH = try_realloc(tmpClosEnv->lexicalAddrH, sizeof(int) * (tmpClosEnv->numBinds+1));
							}

							//fprintf(stderr, "<new>");
							tmpClosEnv->binding[tmpClosEnv->numBinds] = str_clone(expr->variable);
							tmpClosEnv->lexicalAddrH[tmpClosEnv->numBinds] = i;
							tmpClosEnv->lexicalAddrV[tmpClosEnv->numBinds] = 1; 

							j = tmpClosEnv->numBinds;
							tmpClosEnv->numBinds++;
						}

						expr->varRefIndex = j;

						//fprintf(stderr, "<%s is %ith in closure>\n", expr->variable, j);
						return expr;
					}

					expr->varRefIndex = i;
					
					return expr;
				}

				tmpEnv = tmpEnv->enclosing;
				last = tmpClosEnv;
				if (tmpClosEnv)
					tmpClosEnv = tmpClosEnv->enclosing;

				depth++;
			} while (tmpEnv);

			fprintf(stderr, "ERROR 23: NOT IN SCOPE %s\nCurrent Environment is: ", expr->variable);
			for (i=0; i<currentEnvironment->numBinds; i++)
				fprintf(stderr, "[%s] ", currentEnvironment->binding[i]);
			fprintf(stderr, "\n");
			exit(EXIT_FAILURE);
				
			return expr;

		default:
			//wtf!?
			fprintf(stderr, "INTERNAL ERROR @ SCOPER CASE");
			exit(EXIT_FAILURE);
	}	
}

void freeEnvironment(Environment *env) {

	int i = 0;

	for (i=0; i<env->numBinds; i++) {
		try_free(env->binding[i]);
	}
	try_free(env->binding);
	try_free(env->lexicalAddrV);
	try_free(env->lexicalAddrH);
	try_free(env->references);
	try_free(env->realAddress);

	try_free(env);
}
