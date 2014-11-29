/*	microScheme Parser	*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "main.h"
#include "lexer.h"
#include "parser.h"
#include "common.h"

extern bool opt_verbose;
extern char **globalIncludeList;
extern int globalIncludeListN;

void parser_initExpr(AST_expr *expr) {
	expr->type = Constant;
	expr->numBody = 0;
	expr->numFormals = 0;
	expr->body = NULL;
	expr->formal = NULL;
	expr->variable = NULL;
	expr->primproc = NULL;
	expr->proc = NULL;
	expr->closure = NULL;
	expr->value = NULL;
}

AST_expr *parser_parseExpr(lexer_tokenNode **token, int numTokens, bool topLevel, bool tailPosition) {
	AST_expr *result = try_malloc(sizeof(AST_expr)); //{ Constant, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, 0, 0, 0};
	parser_initExpr(result);

	lexer_tokenNode **innerTokens = NULL;
	int innerNumTokens = 0;
	int i = 0;
	AST_const *c;
	lexer_tokenNode *innerFile;

	if ((numTokens) == 1) {
		
		switch(token[0]->type) {
			case Numerictoken:
				c = try_malloc(sizeof(AST_const)); 
				c->type = Numconst; 	 

				// We support hex and decimal notations:
				if (strncmp(token[0]->raw, "#x", 2) == 0) {
					c->value = (int) strtol(token[0]->raw + 2, NULL, 16); // Bit of naughty pointer arithmetic...
				} else {
					c->value = atoi(token[0]->raw);
				}				

				c->strvalue = NULL;
				result->value = c; //DEBUG printf("Numeric"); 
				break;
				
			case Booleantoken:	
				c = try_malloc(sizeof(AST_const)); 
				c->type = Booleanconst; 
				c->strvalue = NULL;
				if (token[0]->raw[1] == 't') 
					c->value=1; 
				else 
					c->value=0;

				result->value=c;
				break;

			case Chartoken:
				c = try_malloc(sizeof(AST_const));
				c->type = Charconst;
				c->value = (int) token[0]->raw[2];
				c->strvalue = NULL;
				result->value=c;
				break;

			case Stringtoken:
				c = try_malloc(sizeof(AST_const));
				c->type = Stringconst;
				c->strvalue = str_clone(token[0]->raw);
				result->value = c;
				break;

			case Identifier:	
				result->type = Variable;
				result->variable = str_clone(token[0]->raw);
				break;

			case Primword:
				if(strcmp(token[0]->raw, "list") == 0 || strcmp(token[0]->raw, "vector") == 0) {
					fprintf(stderr, ">> ERROR 6a: Procedure '%s' is variadic-primitive, and cannot be used as a value\n", token[0]->raw);
					exit(EXIT_FAILURE);
				} else {
					//fprintf(stderr, ">> ERROR 6: Procedure '%s' is primitive, and cannot be used as a value\n", token[0]->raw);
					//exit(EXIT_FAILURE);					
					result->type = Variable;
					result->variable = str_clone(token[0]->raw);
				}
				
				break;

			case Parens:	
				innerTokens = token[0]->children; 
				innerNumTokens = token[0]->numChildren;
				if (innerNumTokens < 1) {
					c = try_malloc(sizeof(AST_const)); 
					c->type = Emptylistconst; 
					c->strvalue = NULL;
					result->value=c;
					break;
				}

				switch(innerTokens[0]->type) {
					case Keyword:
						switch(innerTokens[0]->keyword) {
							case lambda:
								result->type = Lambda; 
								
								if (innerTokens[1]->type == Parens) {
									result->numFormals = innerTokens[1]->numChildren;
									result->formal = try_malloc(sizeof(char*) * innerTokens[1]->numChildren);
									for (i=0; i<innerTokens[1]->numChildren; i++) {
										if (innerTokens[1]->children[i]->type == Identifier) {
											result->formal[i] = str_clone(innerTokens[1]->children[i]->raw);
										} else {
											fprintf(stderr, "Line %i: ERROR 7: Non-identifier in formal argument list\n", 
												innerTokens[1]->children[i]->fileLine);
											exit(EXIT_FAILURE);
										}
									}
								} else {
									fprintf(stderr, ">> ERROR 8: Malford lambda. No formals given");
									exit(EXIT_FAILURE);
								}
								result->numBody = innerNumTokens-2;
								result->body = try_malloc(sizeof(AST_expr*) * (innerNumTokens-2));
								for (i=2; i<innerNumTokens-1; i++) {
									result->body[i-2] = parser_parseExpr(&innerTokens[i], 1, false, false);
								}
								//Give the last one tail position:
								result->body[innerNumTokens-3] = parser_parseExpr(&innerTokens[innerNumTokens-1], 1, false, true);

								//DEBUG printf("Compound Procedure"); 
								break;




							case ifword:	result->type = Branch; 
								if (innerNumTokens == 3) {
									result->numBody = 2;
									result->body = try_malloc(sizeof(AST_expr*) * 2);
									result->body[0] = parser_parseExpr(&innerTokens[1], 1, false, false); // test
									result->body[1] = parser_parseExpr(&innerTokens[2], 1, false, tailPosition); // conseqence
								} else if (innerNumTokens == 4) {
									result->numBody = 3;
									result->body = try_malloc(sizeof(AST_expr*) * 3);
									result->body[0] = parser_parseExpr(&innerTokens[1], 1, false, false); // test
									result->body[1] = parser_parseExpr(&innerTokens[2], 1, false, tailPosition); // conseqence
									result->body[2] = parser_parseExpr(&innerTokens[3], 1, false, tailPosition); // alternative
								} else {
									fprintf(stderr, ">> ERROR 9: Wrong number of operands to IF form");
									exit(EXIT_FAILURE);
								}
								//DEBUG printf("Conditional Branch"); 
								break;

							case andword:
								if (innerNumTokens == 1) {
									c = try_malloc(sizeof(AST_const)); 
									c->type = Booleanconst; 
									c->value=1;
									result->value=c;
								} else if (innerNumTokens == 2) {
									return parser_parseExpr(&innerTokens[1], 1, false, tailPosition);
								} else {
									result->type = And;
									result->numBody = innerNumTokens-1;
									result->body = try_malloc(sizeof(AST_expr*) * (innerNumTokens-1));

									for (i=1; i<innerNumTokens-1; i++) {
										result->body[i-1] = parser_parseExpr(&innerTokens[i], 1, false, false);
									}

									//Propagate tail position:
									result->body[innerNumTokens-2] = parser_parseExpr(&innerTokens[innerNumTokens-1], 1, false, tailPosition);
								}
								break;

							case orword:
								if (innerNumTokens == 1) {
									c = try_malloc(sizeof(AST_const)); 
									c->type = Booleanconst; 
									c->value=0; 
									result->value=c;
								} else if (innerNumTokens == 2) {
									return parser_parseExpr(&innerTokens[1], 1, false, tailPosition);
								} else {
									result->type = Or;
									result->numBody = innerNumTokens-1;
									result->body = try_malloc(sizeof(AST_expr*) * (innerNumTokens-1));

									for (i=1; i<innerNumTokens-1; i++) {
										result->body[i-1] = parser_parseExpr(&innerTokens[i], 1, false, false);
									}

									//Propagate tail position:
									result->body[innerNumTokens-2] = parser_parseExpr(&innerTokens[innerNumTokens-1], 1, false, tailPosition);
								}
								break;



							case set:		
								if (innerNumTokens == 3) {
									if (innerTokens[1]->type == Identifier) {
										result->type = Assignment;
										result->variable = str_clone(innerTokens[1]->raw);
										result->body = try_malloc(sizeof(AST_expr*));
										result->numBody = 1;
										result->body[0] = parser_parseExpr(&innerTokens[2], 1, false, false);
									} else {
										fprintf(stderr, ">> ERROR 10: First operand to SET should be IDENTIFIER");
										exit(EXIT_FAILURE);
									}
								} else {
									fprintf(stderr, ">> ERROR 11: Wrong number of operands to SET form");
									exit(EXIT_FAILURE);
								}
								//DEBUG printf("Assignment"); 
								break;




							case define:
								if (topLevel) {
									if (innerNumTokens < 2) {
										fprintf(stderr, ">> ERROR 12: Wrong number of operands to DEFINE form\n");
										exit(EXIT_FAILURE);
									}

									if (innerTokens[1]->type == Identifier) {
										result->type = Definition;
										result->variable = str_clone(innerTokens[1]->raw);

										if (innerNumTokens == 3) {
											result->numBody = 1;
											result->body = try_malloc(sizeof(AST_expr*));
											result->body[0] = parser_parseExpr(&innerTokens[2], 1, false, false);
										} else if (innerNumTokens == 2) {
											result->numBody = 0;
										} else {
											fprintf(stderr, ">> ERROR 12: Wrong number of operands to DEFINE form\n");
											exit(EXIT_FAILURE);
										}
									} else if (innerTokens[1]->type == Parens) {
										result->type = Definition;
										result->variable = str_clone(innerTokens[1]->children[0]->raw);
										result->numBody = 1;
										result->body = try_malloc(sizeof(AST_expr*));

										result->body[0] = try_malloc(sizeof(AST_expr));
										parser_initExpr(result->body[0]);
										result->body[0]->type = Lambda; 
										result->body[0]->variable = str_clone(innerTokens[1]->children[0]->raw);



											result->body[0]->numFormals = innerTokens[1]->numChildren - 1;
											result->body[0]->formal = try_malloc(sizeof(char*) * (innerTokens[1]->numChildren - 1));
											for (i=1; i<innerTokens[1]->numChildren; i++) {
												if (innerTokens[1]->children[i]->type == Identifier) {
													result->body[0]->formal[i-1] = str_clone(innerTokens[1]->children[i]->raw);
												} else {
													fprintf(stderr, "Line %i: ERROR 13: Non-identifier in formal argument list\n", 
														innerTokens[1]->children[i]->fileLine);
													exit(EXIT_FAILURE);
												}
											}
											
											result->body[0]->numBody = innerNumTokens-2;
											result->body[0]->body = try_malloc(sizeof(AST_expr*) * (innerNumTokens-2));
											for (i=2; i<innerNumTokens-1; i++) {
												result->body[0]->body[i-2] = parser_parseExpr(&innerTokens[i], 1, false, false);
											}
											//Give the last one tail position:
											result->body[0]->body[innerNumTokens-3] = parser_parseExpr(&innerTokens[innerNumTokens-1], 1, false, true);

									} else {
										fprintf(stderr, ">> ERROR 14: First operand to DEFINE should be IDENTIFIER or PARENS\n");
										exit(EXIT_FAILURE);
									}
								} else {
									fprintf(stderr, ">> ERROR 15: Definition not allowed here\n");
									exit(EXIT_FAILURE);
								} break;

							case begin:		
								result->type = Sequence; 
								result->numBody = innerNumTokens-1;
								result->body = try_malloc(sizeof(AST_expr*) * (innerNumTokens-1));
								for (i=1; i<innerNumTokens - 1; i++) {
									result->body[i-1] = parser_parseExpr(&innerTokens[i], 1, false, false);
								}

								result->body[innerNumTokens-2] = parser_parseExpr(&innerTokens[innerNumTokens-1], 1, false, tailPosition);
								//DEBUG printf("Sequence %i", innerNumTokens-1); 
								break;




							case let:		
								if (innerNumTokens >= 3 && innerTokens[1]->type == Parens) {
									result->type = ProcCall;
									result->numBody = innerTokens[1]->numChildren;
									result->body = try_malloc(sizeof(AST_expr*) * innerTokens[1]->numChildren);

									result->proc = try_malloc(sizeof(AST_expr));
									parser_initExpr(result->proc);
									result->proc->type = Lambda;
									result->proc->numFormals = innerTokens[1]->numChildren;
									result->proc->formal = try_malloc(sizeof(char*) * innerTokens[1]->numChildren);
									

									for (i = 0; i < innerTokens[1]->numChildren; i++) {
										if (innerTokens[1]->children[i]->type == Parens && innerTokens[1]->children[i]->numChildren == 2 
											&& innerTokens[1]->children[i]->children[0]->type == Identifier) {
											// lhs of current binding:
											result->proc->formal[i] = str_clone(innerTokens[1]->children[i]->children[0]->raw);
											// rhs of current binding:
											result->body[i] = parser_parseExpr(&innerTokens[1]->children[i]->children[1], 1, false, false);
										} else {
											fprintf(stderr, ">> ERROR 16: Malformed Binding");
											exit(EXIT_FAILURE);
										}
										
									}

									// build result->proc->body
									result->proc->numBody = innerNumTokens-2;
									result->proc->body = try_malloc(sizeof(AST_expr*) * (innerNumTokens-2));
									for (i=0; i<innerNumTokens - 2; i++) {
										result->proc->body[i] = parser_parseExpr(&innerTokens[i+2], 1, false, false);
									}

									// Add the (free-current-closure!)
									/*result->proc->body[innerNumTokens-2] = try_malloc(sizeof(AST_expr));
									parser_initExpr(result->proc->body[innerNumTokens-2]);
									result->proc->body[innerNumTokens-2]->type = PrimCall;
									result->proc->body[innerNumTokens-2]->primproc = str_clone("free-current-closure!!");
									result->proc->body[innerNumTokens-2]->numBody = 0;
									result->proc->body[innerNumTokens-2]->body = NULL;*/
										

								} else {
									fprintf(stderr, ">> ERROR 17: Malformed LET");
									exit(EXIT_FAILURE);
								}
							//DEBUG printf("Local Variable Block"); 
								break;

							case includeword:
							if (innerNumTokens == 2) {
								if (innerTokens[1]->type == Stringtoken) {
									bool alreadyincluded = false;
									for (i = 0; i<globalIncludeListN; i++) {
										if (strcmp(innerTokens[1]->raw, globalIncludeList[i]) == 0) {
											if (opt_includeonce) {
												fprintf(stderr, ">> File '%s' already included, skipping.\n", innerTokens[1]->raw);
												alreadyincluded = true;
											} else {
												fprintf(stderr, ">> Note: '%s' included again, consider compiling without '-i'.\n", innerTokens[1]->raw);
											}

											// insert a placeholder #f in the AST:
											c = try_malloc(sizeof(AST_const));
											c->type = Booleanconst;
											c->strvalue = NULL;
											c->value=0;
											result->value=c;
										}
									}

									if (!alreadyincluded) {
										globalIncludeListN = globalIncludeListN + 1;
										globalIncludeList = try_realloc(globalIncludeList, globalIncludeListN * sizeof(char*));
										globalIncludeList[globalIncludeListN - 1] = str_clone(innerTokens[1]->raw);

										if (opt_verbose) fprintf(stderr, ">> Including file '%s' ", innerTokens[1]->raw);
										fileLine++;
										innerFile = lexer_lexFile(innerTokens[1]->raw, NULL);
										free(result);
										result = parser_parseFile(innerFile->children, innerFile->numChildren, topLevel);
										// Pass on topLevel. So if an (include x) is at the top level, then defines are allowed within it.s
										lexer_freeTokenTree(innerFile);
									}

								} else {
									fprintf(stderr, ">> ERROR 18: First operand to INCLUDE should be STRING\n");
									exit(EXIT_FAILURE);
								}
							} else {
								fprintf(stderr, ">> ERROR 19: Wrong number of operands to INCLUDE form\n");
								exit(EXIT_FAILURE);
							}
							break;
						} break;
					case Primword:
						result->type = PrimCall;
						result->primproc = str_clone(innerTokens[0]->raw);
						result->numBody = innerNumTokens-1;
						result->body = try_malloc(sizeof(AST_expr*) * (innerNumTokens-1));
						for (i=1; i<innerNumTokens; i++) {
							result->body[i-1] = parser_parseExpr(&innerTokens[i], 1, false, false);
						}
						//DEBUG printf("Primitive Procedure Call"); 
						break;	

					case Identifier: 
					case Parens:
						if (tailPosition) result->type = TailCall; else result->type = ProcCall;
						result->proc = parser_parseExpr(&innerTokens[0], 1, false, false);
						result->numBody = innerNumTokens-1;
						result->body = try_malloc(sizeof(AST_expr*) * (innerNumTokens-1));
						for (i=1; i<innerNumTokens; i++) {
							result->body[i-1] = parser_parseExpr(&innerTokens[i], 1, false, false);
						}
						//DEBUG printf("Procedure Call"); 
						break;

					default:
						fprintf(stderr, ">> ERROR 20: Unknown parenthesized form");
						exit(EXIT_FAILURE);
				} break;
			default:
				fprintf(stderr, ">> ERROR 21: Unknown form\n");
				fprintf(stderr, "%i, %s", token[0]->type, token[0]->raw);
				exit(EXIT_FAILURE);
		}
	} else {
		fprintf(stderr, ">> ERROR 22: Unexpected list of expressions");
		exit(EXIT_FAILURE);
	}

	return result;
}

void parser_freeAST(AST_expr *tree) {
	int i;

	if (tree->value) {
		if(tree->value->strvalue != NULL) {
			try_free (tree->value->strvalue);
		}
		try_free(tree->value);
	}
	try_free(tree->variable);
	try_free(tree->primproc);
	if (tree->closure) freeEnvironment(tree->closure);

	for (i=0; i< tree->numBody; i++) {
		parser_freeAST(tree->body[i]);
	}
	try_free(tree->body);

	if (tree->proc) {
		parser_freeAST(tree->proc);
	}

	for (i=0; i< tree->numFormals; i++) {
		try_free(tree->formal[i]);
	}
	try_free(tree->formal);

	try_free(tree);

}

AST_expr *parser_parseFile(lexer_tokenNode **token, int numTokens, bool topLevel) {
	int i = 0;

	AST_expr *result = try_malloc(sizeof(AST_expr)); //{Sequence, NULL, NULL, NULL, 0, NULL, numTokens, NULL, NULL};
	parser_initExpr(result);
	result->type = Sequence;
	result->body = try_malloc(sizeof(AST_expr*) * numTokens);
	result->numBody = numTokens;
	
	for (i = 0; i < numTokens; i++) {
		result->body[i] = parser_parseExpr(&token[i], 1, true, false);
	}

	return result;
}
