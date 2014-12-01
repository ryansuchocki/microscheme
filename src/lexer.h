/*	microScheme Lexer Header File	*/

#ifndef _LEXER_H_GUARD
#define _LEXER_H_GUARD

// Type definitions
	enum lexer_tokenNodeType {Keyword, Primword, Numerictoken, Identifier, Stringtoken, Booleantoken, Chartoken, Parens, Nulltoken };  
	enum keywordtype {lambda, ifword, let, set, define, begin, andword, orword, includeword};
	typedef struct lexer_tokenNode {enum lexer_tokenNodeType type; enum keywordtype keyword; char *raw; 
		struct lexer_tokenNode **children; int numChildren; struct lexer_tokenNode *parent; int fileLine;} lexer_tokenNode;

// Shared variable declarations
//	extern lexer_tokenNode *lexer_openNode;
	extern int fileLine;

// Shared function declarations
	extern void lexer_lex(char ch);
	extern void lexer_freeTokenTree(lexer_tokenNode* tree);
	extern lexer_tokenNode *lexer_lexFile(char *filename, lexer_tokenNode *root);
	extern lexer_tokenNode *lexer_lexBlob(unsigned char *blob, unsigned int length, lexer_tokenNode *root);

#endif