/*	microScheme Parser Header File	*/

#ifndef _PARSER_H_GUARD
#define _PARSER_H_GUARD

// Type definitions
	enum AST_constType { Booleanconst, Charconst, Stringconst, Numconst, Emptylistconst };
	typedef struct AST_const { enum AST_constType type;	int value; char *strvalue;} AST_const;
	enum AST_exprType { Constant, Variable, Lambda, Branch, Definition, Assignment, Sequence, ProcCall, And, Or, PrimCall, TailCall};
	enum AST_varRefType { Local, Free, Global };
	typedef struct AST_expr { enum AST_exprType type; struct AST_const *value; char *variable; char **formal; int numFormals;
		struct AST_expr **body; int numBody; char *primproc; struct AST_expr *proc; enum AST_varRefType varRefType; int varRefHop;
		int varRefIndex; struct Environment *closure; bool stack_allocate; } AST_expr;

// Shared function declarations
	extern AST_expr *parser_parseExpr(lexer_tokenNode **token, int numTokens, bool topLevel, bool tailPosition);
	extern AST_expr *parser_parseFile(lexer_tokenNode **token, int numTokens);
	extern void parser_freeAST(AST_expr *tree);
	extern void parser_initExpr(AST_expr *expr);

#endif