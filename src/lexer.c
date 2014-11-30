/*	microScheme Lexer	*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>


#include "lexer.h"
#include "common.h"


extern bool opt_verbose;

int fileLine = 1;

char** keywords = (char *[]){	"lambda", "if", "let", "set!", "define", "begin", "and", "or", "include"};
int keywordsi = 9;

char** primwords = (char *[]){	"=", ">", ">=", "<", "<=", "not", "¬",
								"+", "-", "*", "div", "mod", "zero?",
								"number?", "pair?", "vector?", "procedure?", "char?", "boolean?", "null?",
								"cons", "car", "cdr", "set-car!", "set-cdr!", "list",
								"vector", "vector-length", "vector-ref", "vector-set!", "make-vector!",
								"assert", "error", "stacksize", "heapsize", "pause", "micropause",
								"serial-send", "digital-state", "set-digital-state",
								"char->number",
								"free!", "arity", /*"free-current-closure!!", "free-pair!!",*/
								"@if-model-mega", "@if-model-uno", "@if-model-leo"	};
int primwordsi = 46;


lexer_tokenNode *lexer_openNode = NULL;

#define TOKEN_BUFFER_LENGTH 100

char acc[TOKEN_BUFFER_LENGTH];
int acci = 0;

int inString = 0, inComment = 0;

void addChild(lexer_tokenNode *child, lexer_tokenNode *parent) {
	if (parent->numChildren == 0)
		parent->children=try_malloc(sizeof(lexer_tokenNode*));
	else
		parent->children=try_realloc(parent->children, sizeof(lexer_tokenNode*)*(parent->numChildren + 1));
	
	parent->children[parent->numChildren] = child;
	parent->numChildren = parent->numChildren + 1;
}

void classify(char *acc, int acci, lexer_tokenNode *parent) {
	acc[acci] = 0;

	lexer_tokenNode *new;
	new = (lexer_tokenNode*) try_malloc(sizeof(lexer_tokenNode));
	new->children = NULL;
	new->raw = NULL;

	char *newRaw = (char*) try_malloc(sizeof(char) * (acci + 1));

	strncpy(newRaw, acc, acci);
	newRaw[acci] = 0;

	int matched = 0;
	int i = 0;

	if (newRaw[0] == '#' && acci > 1) {
		if (acci == 2 && (newRaw[1] == 'f' || newRaw[1] == 't')) {
			new->type = Booleantoken;
			matched = 1;

		} else if (acci == 3 && newRaw[1] == '\\') {
			new->type = Chartoken;
			matched = 1;

		} else if (strcmp(newRaw, "#\\lparen") == 0) {
			new->type = Chartoken;
			newRaw[2] = '(';
			matched = 1;

		} else if (strcmp(newRaw, "#\\rparen") == 0) {
			new->type = Chartoken;
			newRaw[2] = ')';
			matched = 1;

		} else if (strcmp(newRaw, "#\\newline") == 0) {
			new->type = Chartoken;
			newRaw[2] = '\n';
			matched = 1;
			
		} else if (strcmp(newRaw, "#\\space") == 0) {
			new->type = Chartoken;
			newRaw[2] = ' ';
			matched = 1;
		}

		else if (strncmp(newRaw, "#x", 2) == 0) {
			new->type = Numerictoken;
			matched = 1;
		}

		else if (strncmp(newRaw, "#b", 2) == 0) {
			new->type = Numerictoken;
			matched = 1;
		}

	}

	for (i = 0; i < keywordsi; i++) {
		if (strcmp(newRaw, keywords[i]) == 0) {
			new->type = Keyword;
			new->keyword = i;
			matched = 1;
			break;
		}
	}

	if (!matched) {
		for (i = 0; i < primwordsi; i++) {
			if (strcmp(newRaw, primwords[i]) == 0) {
				new->type = Primword;
				new->raw = newRaw;
				new->keyword = i;
				matched = 1;
				break;
			}
		}
	}

	if (!matched) {
		for (i = 0; i < acci; i++) {
			if (newRaw[i] > '9' || newRaw[i] < '0') {
				new->type = Identifier;
				matched = 1;

				if (newRaw[0] >= '0' && newRaw[0] <= '9') {
					printf("%i: ERROR 10 Identifier cannot start with a digit.", fileLine);
					exit(EXIT_FAILURE);
				}
			}
		}
	}

	if (!matched) new->type = Numerictoken;

	new->raw = newRaw;
	new->children = NULL;
	new->numChildren = 0;
	new->parent = parent;
	new->fileLine = fileLine;

	addChild(new, parent);
}

void lexer_lex(char ch) {
	if (acci == TOKEN_BUFFER_LENGTH) {
		fprintf(stderr, "%i: ERROR 1: Char buffer full. Max token length = %i", fileLine, TOKEN_BUFFER_LENGTH);
		exit(EXIT_FAILURE);
	} else if (inString) {
		if (ch == '"') {
			lexer_tokenNode *new;
			new = (lexer_tokenNode*) try_malloc(sizeof(lexer_tokenNode));

			char *newRaw = (char*) try_malloc(sizeof(char) * (acci + 1));

			strncpy(newRaw, acc, acci);
			newRaw[acci] = 0;

			new->type = Stringtoken;

			new->raw = newRaw;
			new->children = NULL;
			new->numChildren = 0;
			new->parent = lexer_openNode;
			new->fileLine = fileLine;

			addChild(new, lexer_openNode);
			inString = 0;
			acci = 0;
			acc[0] = 0;
		} else
			acc[acci++] = ch;
	} else if (inComment) {
		if (ch == '\n') {
			fileLine++;
			inComment = 0;
		}
	} else {
		switch (ch) {
			case ';':	if (acci > 0) {
							fprintf(stderr, "ERROR 3: Comment before end of token");
							exit(EXIT_FAILURE);
						}
						inComment = 1;
						break;
			case '"':	inString = 1;
						break;
			case ' ':
			case '\n':
			case '\r':
			case '\t':	if (acci > 0) {
							classify(acc, acci, lexer_openNode);
							acci = 0;
						}

						if (ch == '\n')
							fileLine++;
						break;
			case '(':	if (acci > 0) {
							classify(acc, acci, lexer_openNode);
							acci = 0;
						}

						// Construct new parens
						lexer_tokenNode *new;
						new = (lexer_tokenNode*) try_malloc(sizeof(lexer_tokenNode));

						new->type = Parens;
						new->raw = NULL;
						new->children = NULL;
						new->numChildren = 0;
						new->parent = lexer_openNode;

						// Add the new parens to the children of the lexer_openNode one
						addChild(new, lexer_openNode);

						// Make the new parens lexer_openNode
						lexer_openNode = new;
						
						break;
			case ')':	if (lexer_openNode->parent == NULL) {
							fprintf(stderr, "%i: ERROR 4: Extraneous )\n", fileLine);
							exit(EXIT_FAILURE);
						}

						if (acci > 0) {
							classify(acc, acci, lexer_openNode);
							acci = 0;
						}

						lexer_openNode = lexer_openNode->parent;
						break;
			default:	acc[acci++] = ch;
		}
	}
}

void lexer_freeTokenTree(lexer_tokenNode* tree) {
	int i;

	for (i=0; i< tree->numChildren; i++) {
		lexer_freeTokenTree(tree->children[i]);
	}

	try_free(tree->children);
	try_free(tree->raw);

	try_free(tree);
}

lexer_tokenNode *lexer_lexFile(char *filename, lexer_tokenNode *root) {
	char ch;
	FILE *fp;
	int err = 0;

	fileLine = 1;

	if (root == NULL) {
		root = try_malloc(sizeof(lexer_tokenNode));
		root->type = Parens;
		root->raw = NULL;
		root->children = NULL;
		root->numChildren = 0;
		root->parent = lexer_openNode;
	}
	

	lexer_openNode = root;



	
	fp = fopen(filename, "r"); // read mode
	if (fp) {
		if (opt_verbose) fprintf(stderr, ">> '%s' found.\n", filename);
	} else {
		fprintf(stderr, ">> ERROR 2:\n>> ");
		perror(filename);
		exit(EXIT_FAILURE);
	}

	while( ( ch = fgetc(fp) ) != EOF ) 
		lexer_lex(ch);

	if (lexer_openNode != root) {
		fprintf(stderr, "In file '%s'\n", filename);
		fprintf(stderr, "ERROR 5: Missing )\n");
		exit(EXIT_FAILURE);
	}
	fclose(fp);
	lexer_openNode = root->parent;
	return root;
}

lexer_tokenNode *lexer_lexBlob(unsigned char *blob, unsigned int length, lexer_tokenNode *root) {
	char ch;

	int err = 0;
	
	if (root == NULL) {
		root = try_malloc(sizeof(lexer_tokenNode));
		root->type = Parens;
		root->raw = NULL;
		root->children = NULL;
		root->numChildren = 0;
		root->parent = lexer_openNode;
	}

	lexer_openNode = root;
	
	int i;
	for (i = 0; i < length; i++) {
		lexer_lex(blob[i]);
	}
	


	if (lexer_openNode != root) {
		fprintf(stderr, "In file '%s'\n", "<INTERNAL!>");
		fprintf(stderr, "ERROR 5: Missing )\n");
		exit(EXIT_FAILURE);
	}

	lexer_openNode = root->parent;
	return root;
}
