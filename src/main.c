/* ======================= Microscheme =======================
 * Main Program
 * (C) 2014-2021 Ryan Suchocki, et al.
 * http://github.com/ryansuchocki/microscheme
 */

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
//#include <fcntl.h>   /* File control definitions */
//#include <errno.h>   /* Error number definitions */

#include "codegen.h"
#include "common.h"
#include "lexer.h"
#include "microscheme_hex.h"
#include "models.h"
#include "parser.h"
#include "scoper.h"
#include "treeshaker.h"
//#include "codegen.h"

int opt_includeonce = true, opt_assemble = false,
    opt_upload = false, opt_cleanup = false,
    opt_aggressive = true, opt_verbose = false,
    opt_verify = false, opt_softreset = false;

char *model = "MEGA";
char *device = "";
char *linkwith = "";
char *programmer = "";

int treeshaker_max_rounds = 10;

char **globalIncludeList = NULL;
int globalIncludeListN = 0;

Environment *globalEnv;

void try_execute(char *command)
{
    int result = system(command);

    if (result < 0 || result == 127)
    {
        fprintf(stderr, ">> Command failed. (%i)\n", result);
        exit(EXIT_FAILURE);
    }

    if (result > 0)
    {
        fprintf(stderr, ">> Warning: Command may have failed. (Exit code %i)\n", result);
    }
}

int main(int argc, char *argv[])
{

    // First, we process the user's command-line arguments, which dictate the input file
    // and target processor.

    char *inname, *outname, *basename, *shortbase;
    int c;

    fprintf(stdout, "Microscheme 0.9.4, (C) Ryan Suchocki\n");

    char *helpmsg =
        "\nUsage: microscheme [-aucvrio] [-m model] [-d device] [-p programmer] [-w filename] [-t rounds] program[.ms]\n\n"
        "Option flags:\n"
        "  -a    Assemble (implied by -u) (requires -m)\n"
        "  -u    Upload (requires -d)\n"
        "  -c    Cleanup (removes intermediate files)\n"
        "  -v    Verbose\n"
        "  -r    Verify (Uploading takes longer)\n"
        "  -i    Allow the same file to be included more than once\n"
        "  -o    Disable optimisations  \n"
        "  -h    Show this help message \n\n"
        "Configuration flags:\n"
        "  -m model       Specify a model (UNO/MEGA/LEO...)\n"
        "  -d device      Specify a physical device\n"
        "  -p programmer  Tell avrdude to use a particular programmer\n"
        "  -w files       'Link' with external C or assembly files\n"
        "  -t rounds      Specify the maximum number of tree-shaker rounds\n";

    while ((c = getopt(argc, argv, "hiaucovrm:d:p:t:w:")) != -1)
        switch (c)
        {
            case 'h':
                fprintf(stdout, "%s", helpmsg);
                exit(EXIT_SUCCESS);
                break;
            case 'i': opt_includeonce = false; break;
            case 'u':
                opt_upload = true;
                // fall through
            case 'a': opt_assemble = true; break;
            case 'c': opt_cleanup = true; break;
            //case 's':	opt_softreset = true;		break;
            case 'o': opt_aggressive = false; break;
            case 'v': opt_verbose = true; break;
            case 'r': opt_verify = true; break;
            case 'm': model = optarg; break;
            case 'd': device = optarg; break;
            case 'p': programmer = optarg; break;
            case 'w': linkwith = optarg; break;
            case 't': treeshaker_max_rounds = atoi(optarg); break;
            case '?':
                if (optopt == 'm')
                    fprintf(stderr, "Option -%c requires an argument.\n", optopt);
                else if (isprint(optopt))
                    fprintf(stderr, "Unknown option `-%c'.\n", optopt);
                else
                    fprintf(stderr, "Unknown option character `\\x%x'.\n", optopt);
                return 1;
            default:
                abort();
        }

    if (argc < 2)
    {
        fprintf(stdout, "%s", helpmsg);

        return (EXIT_FAILURE);
    }

    inname = argv[optind];

    basename = str_clone(inname);

#ifdef __WIN32 // Defined for both 32 and 64 bit environments
    char delimit = '\\';
#else
    char delimit = '/';
#endif

    if (strrchr(basename, delimit))
    {
        shortbase = strrchr(basename, delimit) + 1;
    }
    else
    {
        shortbase = basename;
    }

    shortbase[strcspn(shortbase, ".")] = 0;

    outname = str_clone_more(shortbase, 2);
    strcat(outname, ".s");

    if (argc == optind)
    {
        fprintf(stderr, "No input file.\n");
        exit(EXIT_FAILURE);
    }

    if (argc > optind + 1)
    {
        fprintf(stderr, "Multiple input files not yet supported.\n");
        exit(EXIT_FAILURE);
    }

    model_info theModel;
    int i;
    bool found = false;

    for (i = 0; i < numModels; i++)
    {
        if (strcmp(models[i].name, model) == 0)
        {
            theModel = models[i];
            found = true;
        }
    }

    if (!found)
    {
        fprintf(stderr, "Device not supported.\n");
        return EXIT_FAILURE;
    }

    // This function controls the overall compilation process, which is implemented
    // as four seperate phases, invoked in order.

    // 1) Lex the file
    lexer_tokenNode *root = NULL;

    root = lexer_lexBlob(src_primitives_ms, src_primitives_ms_len, root);

    root = lexer_lexBlob(src_stdlib_ms, src_stdlib_ms_len, root);

    root = lexer_lexBlob(src_avr_core_ms, src_avr_core_ms_len, root);

    root = lexer_lexFile(inname, root);

    globalIncludeList = try_malloc(sizeof(char *));
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

    if (opt_aggressive)
    {

        numPurgedGlobals = -1;
        int latestpurge = -2;
        int rounds = 0;

        globalEnv->realAddress = try_malloc(sizeof(int) * globalEnv->numBinds);
        int j;
        for (j = 0; j < globalEnv->numBinds; j++)
        {
            globalEnv->realAddress[j] = 0;
        }

        while ((numPurgedGlobals > latestpurge) && (rounds < treeshaker_max_rounds))
        {
            //fprintf(stderr, ">> ROUND %i\n", roundi);
            rounds++;
            latestpurge = numPurgedGlobals;

            treeshaker_shakeExpr(ASTroot);
            treeshaker_purge();

            //fprintf(stderr, ">> Aggressive: %i globals purged!\n", numPurgedGlobals);
        }

        fprintf(stdout, ">> Treeshaker: After %i rounds: %i globals purged! %i bytes will be reserved.\n", rounds, numPurgedGlobals, numUsedGlobals * 2);

        if (opt_verbose)
        {
            fprintf(stdout, ">> Remaining globals: [");
            int k;
            for (k = 0; k < globalEnv->numBinds; k++)
            {
                if (globalEnv->realAddress[k] >= 0)
                    fprintf(stdout, "%s ", globalEnv->binding[k]);
            }
            fprintf(stdout, "]\n");
        }
    }
    else
    {
        numUsedGlobals = globalEnv->numBinds;
    }

    // 4) Generate code. (Starting with some preamble)

    FILE *outputFile;
    outputFile = fopen(outname, "w");

    if (!outputFile)
    {
        fprintf(stderr, ">> Error! Could not open output file.\n");
        exit(EXIT_FAILURE);
    }

    codegen_emitModelHeader(theModel, outputFile);
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

    char cmd[500];

    if (opt_assemble)
    {
        if (strcmp(model, "") == 0)
        {
            fprintf(stderr, "Model Not Set. Cannot assemble.\n");
            return EXIT_FAILURE;
        }

        fprintf(stderr, ">> Assembling...\n");
        sprintf(cmd, "avr-gcc -mmcu=%s -o %s.elf %s.s %s", theModel.STR_TARGET, shortbase, shortbase, linkwith);

        try_execute(cmd);

        sprintf(cmd, "avr-objcopy --output-target=ihex %s.elf %s.hex", shortbase, shortbase);

        try_execute(cmd);
    }

    // if (opt_softreset && theModel.software_reset) {
    // 	fprintf(stdout, ">> Attempting software reset...\n");
    // 	int fd = -1;
    // 	struct termios options;

    // 	tcgetattr(fd, &options);

    // 	cfsetispeed(&options, B1200);
    // 	cfsetospeed(&options, B1200);

    // 	options.c_cflag |= (CLOCAL | CREAD | CS8 | HUPCL);
    // 	options.c_cflag &= ~(PARENB | CSTOPB);

    // 	tcsetattr(fd, TCSANOW, &options);

    // 	fd = open(device, O_RDWR | O_NOCTTY | O_NDELAY);
    // 	if (fd == -1) {
    // 		fprintf(stderr, ">> Warning: Unable to open %s for soft reset. (%s)\n", device, strerror(errno));
    // 	} else {
    // 		close(fd);
    // 	}
    // }

    if (opt_upload)
    {

        if (strcmp(device, "") == 0)
        {
            fprintf(stderr, "Device Not Set. Cannot upload.\n");
            return EXIT_FAILURE;
        }

        if (strcmp(programmer, "") == 0)
        {
            programmer = theModel.STR_PROG;
        }

        fprintf(stderr, ">> Uploading...\n");

        char *opt1, *opt2;
        if (opt_verbose) opt1 = "-v";
        else
            opt1 = "";
        if (opt_verify) opt2 = "";
        else
            opt2 = "-V";

        sprintf(cmd, "avrdude %s %s -p %s -P %s -b %s -c %s -D -U flash:w:%s.hex:i", opt1, opt2, theModel.STR_TARGET, device, theModel.STR_BAUD, programmer, shortbase);

        try_execute(cmd);
    }

    if (opt_cleanup)
    {
        fprintf(stdout, ">> Cleaning Up...\n");

#ifdef __WIN32 // Defined for both 32 and 64 bit environments
        sprintf(cmd, "del %s.s %s.elf %s.hex", shortbase, shortbase, shortbase);
#else
        sprintf(cmd, "rm -f %s.s %s.elf %s.hex", shortbase, shortbase, shortbase);
#endif

        try_execute(cmd);
    }

    fprintf(stdout, ">> Finished.\n");

    try_free(basename);
    try_free(outname);

    for (i = 0; i < globalIncludeListN; i++)
        try_free(globalIncludeList[i]);

    try_free(globalIncludeList);

    return EXIT_SUCCESS;
}
