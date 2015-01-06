/*	microScheme Compiler version 0.8
	by Ryan Suchocki.
	University of Warwick, UK
	November 2013
	www.ryansuchocki.co.uk	
	microscheme.org                */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <ctype.h>

#include "lexer.h"
#include "parser.h"
#include "scoper.h"
#include "codegen.h"
#include "common.h"
#include "treeshaker.h"
#include "microscheme_hex.h"
//#include "codegen.h"

int opt_includeonce = true, opt_assemble = false, 
	opt_upload = false, opt_cleanup = false, 
	opt_primitives = true, opt_stdlib = true, 
	opt_aggressive = true, opt_verbose = false, 
	opt_verify = false;

char* model = "MEGA";
char* device = "";
char* linkwith = "";

int treeshaker_max_rounds = 10;

char **globalIncludeList = NULL;
int globalIncludeListN = 0;

Environment *globalEnv;

void try_execute(char *command) {
	int result = system(command);

	if (result < 0 || result == 127) {
		fprintf(stderr, ">> Command failed. [%i]\n", result);
		exit(EXIT_FAILURE);
	}
}

int main(int argc, char *argv[]) {

	// First, we process the user's command-line arguments, which dictate the input file
	// and target processor.

	char *inname, *outname, *basename;
	int c;

	while ((c = getopt(argc, argv, "iaucpsovrm:d:t:w:")) != -1)
	switch (c)	{
		case 'i':	opt_includeonce = false;	break;
		case 'u':	opt_upload = true;			
		case 'a':	opt_assemble = true;		break;
		case 'c':	opt_cleanup = true;			break;
		case 'p':	opt_primitives = false;		break;
		case 's':	opt_stdlib = false;			break;
		case 'o':	opt_aggressive = false;		break;
		case 'v':	opt_verbose = true;			break;
		case 'r':	opt_verify = true;			break;
		case 'm':	model = optarg;				break;
		case 'd':	device = optarg;			break;
		case 'w':	linkwith = optarg;			break;
		case 't':	treeshaker_max_rounds = atoi(optarg);	break;
		case '?':
			if (optopt == 'm')
				fprintf (stderr, "Option -%c requires an argument.\n", optopt);
			else if (isprint (optopt))
				fprintf (stderr, "Unknown option `-%c'.\n", optopt);
			else
				fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
			return 1;
		default:
			abort ();
	}

	fprintf(stdout, "Microscheme 0.8, (C) Ryan Suchocki\n");

	if (argc < 2) {
		fprintf(stdout, "usage: microscheme [-iaucpsov] [-m model] [-d device] [-t treeshaker-rounds] program[.ms]\n");
		return(EXIT_FAILURE);
	}

	inname=argv[optind];

	basename=str_clone(inname);
	basename[strcspn(inname, ".")] = 0;

	outname=str_clone_more(basename, 2);
	strcat(outname, ".s");

	if (argc == optind) {
		fprintf(stderr, "No input file.\n");
		exit(EXIT_FAILURE);
	}

	if (argc > optind + 1) {
		fprintf(stderr, "Multiple input files not yet supported.\n");
		exit(EXIT_FAILURE);
	}








	// This function controls the overall compilation process, which is implemented
	// as four seperate phases, invoked in order.

	// 1) Lex the file
	lexer_tokenNode *root = NULL;

	if (opt_primitives)
		root = lexer_lexBlob(src_primitives_ms, src_primitives_ms_len, root);

	if (opt_stdlib)
		root = lexer_lexBlob(src_stdlib_ms, src_stdlib_ms_len, root);

	root = lexer_lexFile(inname, root);

	globalIncludeList = try_malloc(sizeof(char*));
	globalIncludeList[0] = str_clone(inname);
	globalIncludeListN = 1;

	// 2) Parse the file
	AST_expr *ASTroot = parser_parseFile(root->children, root->numChildren);

	// (We can free the memory used by the lexer once the parser has finished)...
	lexer_freeTokenTree(root);

	// We set up a global environment:
	globalEnv = try_malloc(sizeof(Environment));
	scoper_initEnv(globalEnv);

	// And hand it to the scoper...
	currentEnvironment = globalEnv;

	// At the top level, there is no 'current closure', and hence no 'current closure environment'
	currentClosureEnvironment = NULL;

	// 3) Scope the file:
	ASTroot = scoper_scopeExpr(ASTroot);

	numPurgedGlobals = -1;
	int latestpurge = -2;
	int rounds = 0;

	if (opt_aggressive) {
		globalEnv->realAddress = try_malloc(sizeof(int) * globalEnv->numBinds);
		int i;
		for (i = 0; i < globalEnv->numBinds; i++) {
			globalEnv->realAddress[i] = 0;
		}

		while ((numPurgedGlobals > latestpurge) && (rounds < treeshaker_max_rounds)) {
			//fprintf(stderr, ">> ROUND %i\n", roundi);
			rounds++;
			latestpurge = numPurgedGlobals;

			treeshaker_shakeExpr(ASTroot);
			treeshaker_purge();

			//fprintf(stderr, ">> Aggressive: %i globals purged!\n", numPurgedGlobals);
		} 

		fprintf(stdout, ">> Treeshaker: After %i rounds: %i globals purged! %i bytes will be reserved.\n", rounds, numPurgedGlobals, numUsedGlobals * 2);

		if (opt_verbose) {
			fprintf(stdout, ">> Remaining globals: [");
			int i;
			for (i = 0; i < globalEnv->numBinds; i++) {
				if (globalEnv->realAddress[i] >= 0)
					fprintf(stdout, "%s ", globalEnv->binding[i]);
			}
			fprintf(stdout, "]\n");
		}

		
	} else {
		numUsedGlobals = globalEnv->numBinds;
	}

	// 4) Generate code. (Starting with some preamble)



	FILE *outputFile;
	outputFile = fopen(outname, "w");

		codegen_emitModelHeader(model, outputFile);
		codegen_emitPreamble(outputFile);

		// Next, we recursively emit code for the actual program body:
		codegen_emit(ASTroot, 0, outputFile);

		// Finally, we emit some postamble code
		codegen_emitPostamble(outputFile);

	fclose(outputFile);

	// Finally, the memory allocated during parsing can be freed.
	parser_freeAST(ASTroot);
	freeEnvironment(globalEnv);

	// If we've reached this stage, then everything has gone OK:
	fprintf(stdout, ">> %i lines compiled OK\n", fileLine);






	char cmd[100];
	char *STR_LEVEL, *STR_TARGET, *STR_PROG, *STR_BAUD;

	if (strcmp(model, "MEGA") == 0) {
		STR_LEVEL  = "atmega2560";
		STR_TARGET = "atmega2560";
		STR_PROG   = "wiring";
		STR_BAUD   = "115200";
	} else if (strcmp(model, "UNO") == 0) {
		STR_LEVEL  = "atmega328p";
		STR_TARGET = "atmega328p";
		STR_PROG   = "arduino";
		STR_BAUD   = "115200";
	} else if (strcmp(model, "LEO") == 0) {
		STR_LEVEL  = "atmega32u4";
		STR_TARGET = "atmega32u4";
		STR_PROG   = "arduino";
		STR_BAUD   = "115200";
	} else {
		fprintf(stderr, "Device not supported.\n");
		return EXIT_FAILURE;
	}




	if (opt_assemble) {
		if (strcmp(model, "") == 0) {
			fprintf(stderr, "Model Not Set. Cannot assemble.\n");
			return EXIT_FAILURE;
		}

		fprintf(stderr, ">> Assembling...\n");
		sprintf(cmd, "avr-gcc -mmcu=%s -o %s.elf %s.s %s", STR_LEVEL, basename, basename, linkwith);

		try_execute(cmd);

		sprintf(cmd, "avr-objcopy --output-target=ihex %s.elf %s.hex", basename, basename);
		
		try_execute(cmd);
	}

	if (opt_upload) {

		if (strcmp(device, "") == 0) {
			fprintf(stderr, "Device Not Set. Cannot upload.\n");
			return EXIT_FAILURE;
		}

		fprintf(stderr, ">> Uploading...\n");

		char *opt1, *opt2;
		if (opt_verbose) opt1 = "-v"; else opt1 = "";
		if (opt_verify) opt2 = ""; else opt2 = "-V";

		sprintf(cmd, "avrdude %s %s -p %s -c %s -P %s -b %s -D -U flash:w:%s.hex:i", opt1, opt2, STR_TARGET, STR_PROG, device, STR_BAUD, basename);
		
		try_execute(cmd);
	}

	if (opt_cleanup) {
		fprintf(stdout, ">> Cleaning Up...\n");

		#ifdef __WIN32 // Defined for both 32 and 64 bit environments
			sprintf(cmd, "del %s.s %s.elf %s.hex", basename, basename, basename);
		#else
			sprintf(cmd, "rm -f %s.s %s.elf %s.hex", basename, basename, basename);
		#endif

		try_execute(cmd);
	}

	fprintf(stdout, ">> Finished.\n");

	try_free(basename);
	try_free(outname);

	int i;
	for (i=0; i<globalIncludeListN; i++)
		try_free(globalIncludeList[i]);

	try_free(globalIncludeList);

	return EXIT_SUCCESS;
}
