/*	microScheme Code Generator	*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "lexer.h"
#include "parser.h"
#include "scoper.h"
#include "common.h"
#include "models.h"

#include "assembly_hex.h"

int if_conseq_unique = 1;
int if_end_unique = 1;
int proc_ret_unique = 1;
int proc_entry_unique = 1;
int proc_after_unique = 1;
int and_end_unique = 1;
int or_end_unique = 1;

extern Environment *globalEnv;
extern bool opt_aggressive;
extern char *model;

void codegen_emit(AST_expr *expr, int parent_numArgs, FILE *outputFile) {
	int i, label1, label2, n;
	Environment *closureEnvironment;

	switch(expr->type) {
		case Sequence: 
			for (i=0; i<expr->numBody; i++)
				codegen_emit(expr->body[i], parent_numArgs, outputFile);
			break;

		case Constant: 
			switch (expr->value->type) {
				case Numconst: 
					if (expr->value->value >= 32768) {fprintf(stderr, "ERROR 24: Integer constant too large"); exit(EXIT_FAILURE);}
					fprintf(outputFile, "\tLDI CRSh, %i\n\tLDI CRSl, %i\n", (expr->value->value >> 8) & 127, expr->value->value & 255);
					break;

				case Booleanconst: 
					if (expr->value->value == 0)
						fprintf(outputFile, "\tLDI CRSh, 254\n\tLDI CRSl, 0\n");
					if (expr->value->value == 1)
						fprintf(outputFile, "\tLDI CRSh, 255\n\tLDI CRSl, 0\n");
					break;

				case Charconst:
					fprintf(outputFile, "\tLDI CRSh, 224\n\tLDI CRSl, %i\n", expr->value->value);
					break;

				case Stringconst: // similar to primcall vector case
					n = strlen(expr->value->strvalue);
					fprintf(outputFile, "\tLDI GP1, lo8(%i)\n\tLDI GP2, hi8(%i)\n\tST X+, GP1\n\tST X+, GP2\n", n, n);

					for (i=0; i<n; i++) {
						fprintf(outputFile, "\tLDI CRSh, 224\n\tLDI CRSl, %i\n\tST X+, CRSl\n\tST X+, CRSh\n", expr->value->strvalue[i]);
					}

					fprintf(outputFile, "\tMOV CRSl, HFPl\n\tMOV CRSh, HFPh\n\tSBIW CRSl, %i\n\tORI CRSh, 160\n", 2+2*n);
					break;

				case Emptylistconst:
					fprintf(outputFile, "\tLDI CRSh, 232\n\tLDI CRSl, 0\n");
					break;
			}
			break;

		case Branch:
			label1 = if_end_unique++;
			label2 = if_conseq_unique++;
			codegen_emit(expr->body[0], parent_numArgs, outputFile);
			fprintf(outputFile, "\tCPSE CRSh, falseReg\n\tJMP if_conseq%i\n", label2);
			if (expr->numBody == 3) codegen_emit(expr->body[2], parent_numArgs, outputFile);
			fprintf(outputFile, "\tJMP if_end%i\nif_conseq%i:\n", label1, label2);
			codegen_emit(expr->body[1], parent_numArgs, outputFile);
			fprintf(outputFile, "if_end%i:\n", label1);
			break;

        case When:
			label1 = if_end_unique++;
			codegen_emit(expr->body[0], parent_numArgs, outputFile);
			fprintf(outputFile, "\tCP CRSh, falseReg\n\tBREQ if_end%i\n", label1);
			for (i=1; i<expr->numBody; i++) {
				codegen_emit(expr->body[i], parent_numArgs, outputFile);
			}
			fprintf(outputFile, "if_end%i:\n", label1);
			break;

		case And:
			label1 = and_end_unique++;
			for (i=0; i<expr->numBody-1; i++) {
				codegen_emit(expr->body[i], parent_numArgs, outputFile);
				fprintf(outputFile, "\tCPSE CRSh, falseReg\n\tRJMP 1f\n\tJMP and_end%i\n1:", label1);
			}
			codegen_emit(expr->body[expr->numBody-1], parent_numArgs, outputFile);
			fprintf(outputFile, "and_end%i:\n", label1);
			break;

		case Or:
			label1 = or_end_unique++;
			for (i=0; i<expr->numBody-1; i++) {
				codegen_emit(expr->body[i], parent_numArgs, outputFile);
				fprintf(outputFile, "\tCPSE CRSh, falseReg\n\tJMP or_end%i\n", label1);
			}
			codegen_emit(expr->body[expr->numBody-1], parent_numArgs, outputFile);
			fprintf(outputFile, "or_end%i:\n", label1);
			break;

		case Variable: 
			switch(expr->varRefType) {
				case Local: 
					fprintf(outputFile, "\tLDD CRSh, Z+%i\n\tLDD CRSl, Z+%i\n", 2*(parent_numArgs - expr->varRefIndex) - 1, 2*(parent_numArgs - expr->varRefIndex));
					break;

				case Free:
					fprintf(outputFile, "\tMOVW CRSl, CCPl\n");

					for (i=1; i < expr->varRefHop; i++) // traverse the closure-chain
						fprintf(outputFile, "\tLDD GP1, Y+3\n\tLDD CRSh, Y+4\n\tMOV CRSl, GP1\n");

					fprintf(outputFile, "\tLDD GP1, Y+%i\n\tLDD CRSh, Y+%i\n\tMOV CRSl, GP1\n", (2 * expr->varRefIndex) + 5, (2 * expr->varRefIndex) + 6);
					break;

				case Global: 
					if (opt_aggressive) {
						//int realAddress = globalEnv->realAddress[expr->varRefIndex];
						//fprintf(outputFile, "\tLDS CRSh, RAM + %i\n\tLDS CRSl, RAM + %i\n", (2 * realAddress), 1 + (2 * realAddress));
						fprintf(outputFile, "\tLDS CRSh, _global_%i+1\n\tLDS CRSl, _global_%i\n", globalEnv->realAddress[expr->varRefIndex], globalEnv->realAddress[expr->varRefIndex]);
							
					} else {
						//fprintf(outputFile, "\tLDS CRSh, RAM + %i\n\tLDS CRSl, RAM + %i\n", (2 * expr->varRefIndex), 1 + (2 * expr->varRefIndex));
						fprintf(outputFile, "\tLDS CRSh, _global_%i+1\n\tLDS CRSl, _global_%i\n", expr->varRefIndex, expr->varRefIndex);
					}
					break;
			}
			break;

		case Definition:
			if (expr->numBody < 1) {
				// Nothing to do
				return;
			}

		case Assignment:
			switch(expr->varRefType) {
				case Local: 
					codegen_emit(expr->body[0], parent_numArgs, outputFile);
					fprintf(outputFile, "\tSTD Z+%i, CRSh\n\tSTD Z+%i, CRSl\n", 2*(parent_numArgs - expr->varRefIndex) - 1, 2*(parent_numArgs - expr->varRefIndex));
					break;

				case Free: 
					codegen_emit(expr->body[0], parent_numArgs, outputFile);
					fprintf(outputFile, "\tMOVW GP1, CRSl\n\tMOVW CRSl, CCPl\n");

					for (i=1; i < expr->varRefHop; i++) // traverse the closure-chain
						fprintf(outputFile, "\tLDD GP3, Y+3\n\tLDD CRSh, Y+4\n\tMOV CRSl, GP3\n");

					fprintf(outputFile, "\tSTD Y+%i, GP1\n\tSTD Y+%i, GP2\n", (2 * expr->varRefIndex) + 5, (2 * expr->varRefIndex) + 6);
					break;

				case Global: 

					if (opt_aggressive) {
						if (globalEnv->realAddress[expr->varRefIndex] >= 0) {
							//int realAddress = globalEnv->realAddress[expr->varRefIndex];
							codegen_emit(expr->body[0], parent_numArgs, outputFile);
							//fprintf(outputFile, "\tSTS RAM + %i, CRSh\n\tSTS RAM + %i, CRSl\n", (2 * realAddress), 1 + (2 * realAddress));
							fprintf(outputFile, "\tSTS _global_%i+1, CRSh\n\tSTS _global_%i, CRSl\n", globalEnv->realAddress[expr->varRefIndex], globalEnv->realAddress[expr->varRefIndex]);
						}
					} else {
						codegen_emit(expr->body[0], parent_numArgs, outputFile);
						//fprintf(outputFile, "\tSTS RAM + %i, CRSh\n\tSTS RAM + %i, CRSl\n", (2 * expr->varRefIndex), 1 + (2 * expr->varRefIndex));
						fprintf(outputFile, "\tSTS _global_%i+1, CRSh\n\tSTS _global_%i, CRSl\n", expr->varRefIndex, expr->varRefIndex);
					}
				
				break;
			}

			break;

		case ProcCall:
			label1 = proc_ret_unique++;
			fprintf(outputFile, "\tPUSH AFPh\n\tPUSH AFPl\n\tPUSH CCPh\n\tPUSH CCPl\n\tLDI GP1, hi8(pm(proc_ret%i))\n\tPUSH GP1\n\tLDI GP1, lo8(pm(proc_ret%i))\n\tPUSH GP1\n", label1, label1);
			for (i=0; i<expr->numBody; i++) {
				codegen_emit(expr->body[i], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSl\n\tPUSH CRSh\n");
			}
			codegen_emit(expr->proc, parent_numArgs, outputFile);

			fprintf(outputFile, "\tIN AFPl, SPl\n\tIN AFPh, SPh\n");
			if (expr->proc->type == Lambda && expr->proc->stack_allocate)
				fprintf(outputFile, "\tADIW AFPl, %i\n", (expr->proc->closure->numBinds * 2) + 5);
			fprintf(outputFile, "\tMOVW GP5, AFPl\n");

			fprintf(outputFile, "\tLDI PCR, %i\n\tJMP proc_call\nproc_ret%i:\n\tPOP CCPl\n\tPOP CCPh\n\tPOP AFPl\n\tPOP AFPh\n", expr->numBody, label1);
			break;

		case TailCall:

			for (i=0; i<expr->numBody; i++) {
				codegen_emit(expr->body[i], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSl\n\tPUSH CRSh\n");
			}

			codegen_emit(expr->proc, parent_numArgs, outputFile);



			fprintf(outputFile, "\tIN GP3, SPl\n");
			fprintf(outputFile, "\tIN GP4, SPh\n");
			if (parent_numArgs > 0)
				fprintf(outputFile, "\tADIW AFPl, %i\n", 2*parent_numArgs);
			fprintf(outputFile, "\tOUT SPl, AFPl\n");
			fprintf(outputFile, "\tOUT SPh, AFPh\n");
			if (expr->numBody > 0)
				fprintf(outputFile, "\tSBIW AFPl, %i\n", 2*expr->numBody);
			fprintf(outputFile, "\tMOVW GP5, AFPl\n");
			fprintf(outputFile, "\tMOVW AFPl, GP3\n");

			if (expr->proc->type == Lambda && expr->proc->stack_allocate)
				fprintf(outputFile, "\tADIW AFPl, %i\n", (expr->proc->closure->numBinds * 2) + 5);

			if (expr->numBody > 0)
				fprintf(outputFile, "\tADIW AFPl, %i\n", 2*expr->numBody);

			fprintf(outputFile, "1:\tCP AFPl, GP3\n");
			fprintf(outputFile, "\tCPC AFPh, GP4\n");
			fprintf(outputFile, "\tBREQ 2f\n");			
			fprintf(outputFile, "\tLD GP1, Z\n");
			fprintf(outputFile, "\tSBIW AFPl, 1\n");
			fprintf(outputFile, "\tPUSH GP1\n");
			fprintf(outputFile, "\tRJMP 1b\n");

			fprintf(outputFile, "2:\tLDI PCR, %i\n", expr->numBody);
			if (expr->proc->type == Lambda && expr->proc->stack_allocate)
				fprintf(outputFile, "\tIN CRSh, SPh\n\tIN CRSl, SPl\n\tADIW CRSl, 1\n\tORI CRSh, 192\n");
			fprintf(outputFile, "\tJMP proc_call\n");

			break;

		case Lambda: 
			label1 = proc_entry_unique++;
			label2 = proc_after_unique++;
			closureEnvironment = expr->closure;

			
			if (expr->stack_allocate) {
				//fprintf(stderr, "stack allocating...");
				fprintf(outputFile, "\tMOVW GP3, HFPl\n\tIN HFPl, SPl\n\tIN HFPh, SPh\n\tSBIW HFPl, %i\n\tOUT SPl, HFPl\n\tOUT SPh, HFPh\n\tADIW HFPl, 1\n", (closureEnvironment->numBinds * 2) + 5);
			}

			fprintf(outputFile, "\tLDI GP1,%i\n\tST X+, GP1;HFP\n\tLDI GP1, hi8(pm(proc_entry%i))\n\tST X+, GP1\n\tLDI GP1, lo8(pm(proc_entry%i))\n\tST X+, GP1\n", expr->numFormals, label1, label1);

			// Set up the closure chain:
			fprintf(outputFile, "\tST X+, CCPl\n\tST X+, CCPh\n");

			for (i=0; i<closureEnvironment->numBinds; i++) {

				if (closureEnvironment->lexicalAddrV[i] == 1) {
					fprintf(outputFile, "\tLDD CRSh, Z+%i\n\tLDD CRSl, Z+%i\n", 2*(parent_numArgs - closureEnvironment->lexicalAddrH[i]) - 1, 2*(parent_numArgs - closureEnvironment->lexicalAddrH[i]));
					fprintf(outputFile, "\tST X+, CRSl\n\tST X+, CRSh\n");

				} else {
					// erm. something's gone wrong?
				}
			}

			char* lambdaname = "Anonymous";
			if (expr->variable != NULL)
				lambdaname = expr->variable;


			fprintf(outputFile, "\tMOVW CRSl, HFPl\n\tSBIW CRSl, %i\n\tORI CRSh, 192\n", (closureEnvironment->numBinds * 2) + 5);

			if (expr->stack_allocate) {
				fprintf(outputFile, "\tMOVW HFPl, GP3\n");
			}

			fprintf(outputFile, "\tJMP proc_after%i\nproc_entry%i: ; %s\n\tMOVW AFPl, GP5\n", label2, label1, lambdaname);
			for (i=0; i<expr->numBody; i++) codegen_emit(expr->body[i], expr->numFormals, outputFile);
			if (expr->body[expr->numBody-1]->type != TailCall) fprintf(outputFile, "\tADIW AFPl, %i\n\tOUT SPl, AFPl\n\tOUT SPh, AFPh\n\tPOP AFPl\n\tPOP AFPh\n\tIJMP\n", 2 * expr->numFormals);
			fprintf(outputFile, "proc_after%i:\n", label2);

			break;

		case OtherFundemental:
			if (strcmp(expr->primproc, "list") == 0) {
				for (i=0; i<expr->numBody; i++) {
					codegen_emit(expr->body[i], parent_numArgs, outputFile);
					fprintf(outputFile, "\tPUSH CRSh\n\tPUSH CRSl\n");
				}

				fprintf(outputFile, "\tLDI CRSh, 232\n\tLDI CRSl, 0\n");

				for (i=0; i<expr->numBody; i++) {
					fprintf(outputFile, "\tPOP GP1\n\tPOP GP2\n\tCALL inline_cons\n");
				}
			}

			else if (strcmp(expr->primproc, "vector") == 0) {

				// Here we do some static analysis, in order to select the faster vector-building routine
				// whenever possible:
				bool all_const = true;

				for (i=0; i<expr->numBody; i++) {
					if (expr->body[i]->type != Constant)
						all_const = false;
				}

				if (all_const) {

					fprintf(outputFile, "\tLDI GP1, lo8(%i)\n\tLDI GP2, hi8(%i)\n\tST X+, GP1\n\tST X+, GP2\n", expr->numBody, expr->numBody);

					for (i=0; i<expr->numBody; i++) {
						codegen_emit(expr->body[i], parent_numArgs, outputFile);
						fprintf(outputFile, "\tST X+, CRSl\n\tST X+, CRSh\n");
					}

					fprintf(outputFile, "\tMOVW CRSl, HFPl\n\tSUBI CRSl, lo8(%i)\n\tSBCI CRSh, hi8(%i)\n\tORI CRSh, 160\n", 2+2*expr->numBody, 2+2*expr->numBody);
				
				} else {

					for (i=expr->numBody-1; i>=0; i--) {
						codegen_emit(expr->body[i], parent_numArgs, outputFile);
						fprintf(outputFile, "\tPUSH CRSh\n\tPUSH CRSl\n");
					}

					fprintf(outputFile, "\tLDI GP1, lo8(%i)\n\tLDI GP2, hi8(%i)\n\tST X+, GP1\n\tST X+, GP2\n", expr->numBody, expr->numBody);

					for (i=0; i<expr->numBody; i++) {
						fprintf(outputFile, "\tPOP CRSl\n\tPOP CRSh\n");
						fprintf(outputFile, "\tST X+, CRSl\n\tST X+, CRSh\n");
					}

					fprintf(outputFile, "\tMOVW CRSl, HFPl\n\tSUBI CRSl, lo8(%i)\n\tSBCI CRSh, hi8(%i)\n\tORI CRSh, 160\n", 2+2*expr->numBody, 2+2*expr->numBody);
				}
			}

			else if (strcmp(expr->primproc, "free!") == 0) {
				fprintf(outputFile, "\tPUSH HFPh\n\tPUSH HFPl\n");

				for (i=0; i<expr->numBody; i++) {
					codegen_emit(expr->body[i], parent_numArgs, outputFile);
				}

				fprintf(outputFile, "\tPOP HFPl\n\tPOP HFPh\n");
			}

			else if (strcmp(expr->primproc, "@if-model") == 0 && expr->numBody == 2) {
				if (strcmp(expr->body[0]->value->strvalue, model) == 0) {
					codegen_emit(expr->body[1], parent_numArgs, outputFile);
				}

			}
			
			else if (strcmp(expr->primproc, "call-c-func") == 0 && expr->numBody > 0 && expr->numBody <= 10) {
				fprintf(outputFile, "\tCALL before_c_func\n");
				
				//load args into (24:25) -> (8:9) descending l:h
				for (i=1; i<expr->numBody; i++) {
					codegen_emit(expr->body[i], parent_numArgs, outputFile);
					fprintf(outputFile, "\tMOV r%i, CRSl\n\tMOV r%i, CRSh\n", 26 - (i * 2), 27 - (i * 2));
				}

				fprintf(outputFile, "\tCALL %s\n\tCALL after_c_func\n", expr->body[0]->value->strvalue);
			}

			else if (strcmp(expr->primproc, "include-asm") == 0 && expr->numBody == 1) {
				fprintf(outputFile, ".include \"%s\"\n", expr->body[0]->value->strvalue);
			}

			else if (strcmp(expr->primproc, "asm") == 0) {
				for (i=0; i<expr->numBody; i++) {
					fprintf(outputFile, "\t%s\n", expr->body[i]->value->strvalue);
				}
			}

			break;


		case PrimCall:
			if ((strcmp(expr->primproc, "=") == 0 || strcmp(expr->primproc, "eq?") == 0) && expr->numBody == 2) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSl\n\tPUSH CRSh\n");
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPOP GP2\n\tPOP GP1\n\tCP GP2, CRSh\n\tBRNE 1f\n\tLDI CRSh, trueHigh\n\tCPSE GP1, CRSl\n\t1:LDI CRSh, falseHigh\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "zero?") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tMOVW GP1, CRSl\n\tCP zeroReg, CRSh\n\tBRNE 1f\n\tLDI CRSh, trueHigh\n\tCPSE zeroReg, CRSl\n\t1:LDI CRSh, falseHigh\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "¬") == 0 && expr->numBody == 1) {
				// A quick, binary-valid not:
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tLDI GP1, 1\n\tEOR CRSh, GP1\n");
			}

			else if (strcmp(expr->primproc, "not") == 0 && expr->numBody == 1) {
				// the (false? ...) version of not:
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tMOVW GP1, CRSl\n\tCP falseReg, CRSh\n\tBRNE 1f\n\tLDI CRSh, trueHigh\n\tCPSE zeroReg, CRSl\n\t1:LDI CRSh, falseHigh\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "+") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPOP GP1\n\tPOP GP2\n\tADD CRSl, GP1\n\tADC CRSh, GP2\n");
			}

			else if (strcmp(expr->primproc, "-") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPOP GP1\n\tPOP GP2\n\tSUB CRSl, GP1\n\tSBC CRSh, GP2\n");
			}

			else if (strcmp(expr->primproc, "*") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPOP GP1\n\tPOP GP2\n\tMOV GP3, CRSh\n\tMOV GP4, CRSl\n\tMUL GP1, GP4\n\tMOV CRSl, MLX1\n\tMOV CRSh, MLX2\n\tMUL GP2, GP4\n\tADD CRSh, MLX1\n\tMUL GP1, GP3\n\tADD CRSh, MLX1\n");
			}

			else if (strcmp(expr->primproc, "div") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPOP GP1\n\tPOP GP2\n\tCALL inline_div\n");
			}

			else if (strcmp(expr->primproc, "mod") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPOP GP1\n\tPOP GP2\n\tCALL inline_div\n");

				fprintf(outputFile, "\tADD GP1, GP3\n\tADC GP2, GP4\n\tMOVW CRSl, GP1\n");
			}

			else if (strcmp(expr->primproc, "stacksize") == 0 && expr->numBody == 0) {
				fprintf(outputFile, "\tIN GP1, SPl\n\tIN GP2, SPh\n\tLDI CRSl, lo8(__stack)\n\tLDI CRSh, hi8(__stack)\n\tSUB CRSl, GP1\n\tSBC CRSh, GP2\n");
			}

			else if (strcmp(expr->primproc, "heapsize") == 0 && expr->numBody == 0) {
				fprintf(outputFile, "\tMOVW CRSl, HFPl\n\tSUBI CRSl, lo8(_end)\n\tSBCI CRSh, hi8(_end)\n");
			}

			else if (strcmp(expr->primproc, "error") == 0 && expr->numBody == 0) {
				fprintf(outputFile, "\tJMP error_custom\n");
			}

			else if (strcmp(expr->primproc, "assert") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSER GP1\n\tCPSE CRSh, GP1\n\tJMP error_custom\n");
			}

			else if (strcmp(expr->primproc, "number?") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tROL CRSh\n\tROL CRSh\n\tANDI CRSh, 1\n\tCOM CRSh\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "pair?") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tORI CRSh, 31\n\tLDI GP1, 159\n\tCPSE CRSh, GP1\n\tCBR CRSh, 1\n\tORI CRSh, 224\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "procedure?") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tORI CRSh, 31\n\tLDI GP1, 223\n\tCPSE CRSh, GP1\n\tCBR CRSh, 1\n\tORI CRSh, 224\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "char?") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tORI CRSh, 7\n\tLDI GP1, 231\n\tCPSE CRSh, GP1\n\tCBR CRSh, 1\n\tORI CRSh, 248\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "boolean?") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tORI CRSh, 7\n\tLDI GP1, 255\n\tCPSE CRSh, GP1\n\tCBR CRSh, 1\n\tORI CRSh, 248\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "null?") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tORI CRSh, 7\n\tLDI GP1, 239\n\tCPSE CRSh, GP1\n\tCBR CRSh, 1\n\tORI CRSh, 248\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "cons") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPOP GP1\n\tPOP GP2\n\tCALL inline_cons\n");
			}

			else if (strcmp(expr->primproc, "car") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tCALL inline_car\n");
			}

			else if (strcmp(expr->primproc, "cdr") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tCALL inline_cdr\n");
			}

			else if (strcmp(expr->primproc, "set-car!") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPOP GP1\n\tPOP GP2\n\tCALL inline_set_car\n");
			}

			else if (strcmp(expr->primproc, "set-cdr!") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPOP GP1\n\tPOP GP2\n\tCALL inline_set_cdr\n");
			}

			else if (strcmp(expr->primproc, "make-vector") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tMOVW GP1, CRSl\n\tMOVW CRSl, HFPl\n\tORI CRSh, 160\n\tST X+, GP1\n\tST X+, GP2\n\tLSL GP1\n\tROL GP2\n\tADD HFPl, GP1\n\tADC HFPh, GP2\n");
			}

			else if (strcmp(expr->primproc, "vector?") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tORI CRSh, 31\n\tLDI GP1, 191\n\tCPSE CRSh, GP1\n\tCBR CRSh, 1\n\tORI CRSh, 224\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "vector-ref") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPOP GP1\n\tPOP GP2\n\tCALL inline_vector_ref\n");
			}

			else if (strcmp(expr->primproc, "vector-set!") == 0 && expr->numBody == 3) {
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[2], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPOP GP3\n\tPOP GP4\n\tPOP GP1\n\tPOP GP2\n\tCALL inline_vector_set\n");
			}

			else if (strcmp(expr->primproc, "vector-length") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tCALL inline_vector_length\n");
			}

			else if (strcmp(expr->primproc, ">") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPOP GP1\n\tPOP GP2\n\tCALL inline_gt\n");
			}

			else if (strcmp(expr->primproc, "<") == 0 && expr->numBody == 2) {
				// (a < b)  ==  (b > a)
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPOP GP1\n\tPOP GP2\n\tCALL inline_gt\n");
			}

			else if (strcmp(expr->primproc, ">=") == 0 && expr->numBody == 2) {
				// (a >= b) == ¬(b > a)
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPOP GP1\n\tPOP GP2\n\tCALL inline_gt\n");
				// NOT:
				fprintf(outputFile, "\tLDI GP1, 1\n\tEOR CRSh, GP1\n");
			}

			else if (strcmp(expr->primproc, "<=") == 0 && expr->numBody == 2) {
				// (a <= b) == ¬(a > b)
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPUSH CRSh\n\tPUSH CRSl\n");
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tSBRC CRSh, 7\n\tJMP error_notnum\n\tPOP GP1\n\tPOP GP2\n\tCALL inline_gt\n");
				// NOT:
				fprintf(outputFile, "\tLDI GP1, 1\n\tEOR CRSh, GP1\n");
			}

			else if (strcmp(expr->primproc, "digital-state") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSl\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPOP GP3\n\tLD GP4, Y\n\tLDI CRSh, trueHigh\n\tAND GP4, GP3\n\tCPSE GP4, GP3\n\tLDI CRSh, falseHigh\n\tCLR CRSl\n");
			}

			else if (strcmp(expr->primproc, "set-digital-state") == 0 && expr->numBody == 3) {
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSl\n");
				codegen_emit(expr->body[2], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSh\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPOP GP4\n\tPOP GP3\n\tLD GP5, Y\n\tOR GP5, GP3\n\tCOM GP3\n\tSBRS GP4, 0\n\tAND GP5, GP3\n\tST Y, GP5\n");					
			}

			else if (strcmp(expr->primproc, "pause") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tCALL util_pause\n");
			}

			else if (strcmp(expr->primproc, "micropause") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tCALL util_micropause\n");
			}

			else if (strcmp(expr->primproc, "char->number") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tCLR CRSh\n");
			}

			else if (strcmp(expr->primproc, "arity") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tMOV GP1, CRSh\n\tANDI GP1, 224\n\tLDI GP2, 192\n\tCPSE GP1, GP2\n\tJMP error_notproc\n\tANDI CRSh, 31\n\tLD GP1, Y;CRS\n\tMOV CRSl, GP1\n\tMOV CRSh, zeroReg\n");
			}

			else if (strcmp(expr->primproc, ">>") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tLSR CRSh\n\tROR CRSl\n");
			}

			else if (strcmp(expr->primproc, "<<") == 0 && expr->numBody == 1) {
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tLSL CRSl\n\tROL CRSh\n");
			}

			else if (strcmp(expr->primproc, "|") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPUSH CRSl\n\tPUSH CRSh\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tPOP GP2\n\tPOP GP1\n\tOR CRSl, GP1\n\tOR CRSh, GP2\n");
			}

			else if (strcmp(expr->primproc, "&") == 0 && expr->numBody == 2) {
				codegen_emit(expr->body[1], parent_numArgs, outputFile);
				fprintf(outputFile, "\tMOVW GP1, CRSl\n");
				codegen_emit(expr->body[0], parent_numArgs, outputFile);
				fprintf(outputFile, "\tAND CRSl, GP1\n\tAND CRSh, GP2\n");
			}

			else {
				fprintf(stderr, "ERROR 26: No primitive '%s' taking %i arguments.\n", expr->primproc, expr->numBody);
				exit(1);
			}

			break;


		
		default: // this state really shouldn't be reached...
			fprintf(outputFile, "ERROR 27: Internal Error");
			exit(EXIT_FAILURE);
	}
}

void copyIn(char *filename, FILE *outputFile) {
	char a;

	FILE *fp = fopen(filename, "r");
	if (fp == NULL) {
		fprintf(stderr, "Internal error. Can't open file '%s'.\n", filename);
		fclose(fp);
		exit(EXIT_FAILURE);
	}
 
	while ((a = fgetc(fp)) != EOF) {
		fputc(a, outputFile);
	}

	fclose(fp);
}

void copyHex(unsigned char* data, unsigned int length, FILE *outputFile) { 
	unsigned int i;

	for (i = 0; i < length; i++) {
		fputc(data[i], outputFile);
	}
}

void codegen_emitPreamble(FILE *outputFile/*, int numUsedGlobals*/) {
	//fprintf(outputFile, ".EQU HEAP_RESERVE, %i\n", numUsedGlobals * 2);

	int i = 0;
	for (i=0; i<globalEnv->numBinds; i++) {
		if (opt_aggressive) {
			if (globalEnv->realAddress[i] >= 0)
				fprintf(outputFile, "\t.global _global_%i\n\t.data\n\t.size _global_%i, 2\n_global_%i:\n\t.word falseHigh\n\t.text\n", globalEnv->realAddress[i], globalEnv->realAddress[i], globalEnv->realAddress[i]);
		} else {
				fprintf(outputFile, "\t.global _global_%i\n\t.data\n\t.size _global_%i, 2\n_global_%i:\n\t.word falseHigh\n\t.text\n", i, i, i);
		}
	}
	
	//fprintf(outputFile, ".include \"include/preamble.s\"\n");
	//copyIn("include/preamble.s", outputFile);
	copyHex(src_preamble_s, src_preamble_s_len, outputFile);
}

void codegen_emitPostamble(FILE *outputFile) {
	fprintf(outputFile, "SBI PORT13, P13\nJMP _exit\n");
}

void codegen_emitModelHeader(model_info theModel, FILE *outputFile) {
	//fprintf(outputFile, ".include \"include/%s.s\"\n");
	//char *filename = str_clone_more("include/.s", strlen(model, expr));
	//sprintf(filename, "include/%s.s");
	//copyIn(filename, outputFile);

	// if (strcmp(model, "MEGA") == 0) {
	// 	copyHex(src_MEGA_s, src_MEGA_s_len, outputFile);
	// } else if (strcmp(model, "UNO") == 0) {
	// 	copyHex(src_UNO_s, src_UNO_s_len, outputFile);
	// } else if (strcmp(model, "LEO") == 0) {
	// 	copyHex(src_LEO_s, src_LEO_s_len, outputFile);
	// }

	unsigned int i;

	for (i = 0; i < strlen(theModel.specific_asm); i++) {
		fputc((unsigned char) theModel.specific_asm[i], outputFile);
	}

}

