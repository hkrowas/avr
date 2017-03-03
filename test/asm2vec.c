/*
   This file converts the information in the .asm file input on stdin to test
   vectors which are output to stdout.  The file has a very fixed format which
   must be followed when creating the .asm file.  For any line that accesses
   data memory the comment must start with R or W (for read or write),
   followed by the data to the read or written, and the address it is read
   from or written to (space separated).  A skeleton VHDL test file is then
   output to stdout.

   Revision History:
      2/24/17  Glen George      Initial revision.
*/




/* library include files */
#include  <ctype.h>
#include  <stdio.h>
#include  <stdlib.h>
#include  <string.h>

/* local include files */
  /* none */


/* definitions */
#define  ALLOC_SIZE     200     /* size of array to allocate at a time */
#define  MAX_LINE_SIZE  300     /* maximum length of a line */
#define  VEC_PER_LINE   5       /* vectors per line */




int  main()
{
    /* variables */
    char  (*data)[3] = NULL;            /* test vector data */
    char  (*rdwr)[2] = NULL;            /* test vector read/write direction */
    char  (*addr)[5] = NULL;            /* test vector address */

    char    line[MAX_LINE_SIZE];        /* a line of input */

    int     no_lines = 0;               /* number of lines processed */

    int     no_vectors = 0;             /* number of vectors stored */
    int     alloc_vectors = 0;          /* number of vectors allocated */

    int     error = 0;                  /* error flag */

    int     i;                          /* loop index */



    /* read lines until done or error */
    while (!error & (fgets(line, MAX_LINE_SIZE, stdin) != NULL))  {

        /* have a line, count it */
        no_lines++;

        /* have a valid line, do we have room for it */
        if (no_vectors >= alloc_vectors)  {

            /* need to allocate more memory */
            alloc_vectors += ALLOC_SIZE;
            data = realloc(data, alloc_vectors * sizeof(char [3]));
            rdwr = realloc(rdwr, alloc_vectors * sizeof(char [2]));
            addr = realloc(addr, alloc_vectors * sizeof(char [5]));

            /* if anything went wrong set the error flag */
            error = ((data == NULL) || (rdwr == NULL) || (addr == NULL));
        }

            
        /* if no error, parse the line */
        if (!error)  {

            /* read/write follows the semi-colon */
            for (i = 0; ((line[i] != '\0') && (line[i] != ';')); i++);

            /* now need to see read or write */
            if ((line[i + 1] == 'r') || (line[i + 1] == 'R'))  {
                /* have a read cycle */
                strcpy(rdwr[no_vectors], "r");
                /* move past the r/w symbol */
                i += 2;
            }
            else if ((line[i + 1] == 'w') || (line[i + 1] == 'W'))  {
                /* have a write cycle */
                strcpy(rdwr[no_vectors], "w");
                /* move past the r/w symbol */
                i += 2;
            }
            else  {
                /* neither read nor write */
                strcpy(rdwr[no_vectors], " ");
            }
        

	    /* if have a read or write cycle, need get data and address */
            if (rdwr[no_vectors][0] != ' ')  {

                /* data follows the next space */
                while ((line[i] != '\0') && !isspace(line[i]))
                    i++;
                /* skip all whitespace */
                while ((line[i] != '\0') && isspace(line[i]))
                    i++;
                strncpy(data[no_vectors], &(line[i]), 2);
                data[no_vectors][2] = '\0';
                /* move past the dat value */
                i += 2;

                /* address follows the space after the data */
                while ((line[i] != '\0') && isspace(line[i]))
                    i++;
                strncpy(addr[no_vectors], &(line[i]), 4);
                addr[no_vectors][4] = '\0';
            }

            /* have another vector */
            no_vectors++;
        }
    }


    /* check if there was an error */
    if (error)
        /* have an error - output a message */
        fprintf(stderr, "Out of memory\n");

    /* output summary results */
    fprintf(stderr, "Lines processed: %d\n", no_lines);
    fprintf(stderr, "Vectors generated: %d\n", no_vectors);


    /* output header information */
    puts("library ieee;");
    puts("use ieee.std_logic_1164.all;");
    puts("use ieee.std_logic_arith.all;");
    puts("use ieee.std_logic_unsigned.all;");
    puts("use ieee.numeric_std.all;");
    puts("");
    puts("library OpCodes;");
    puts("use OpCodes.OpCodes.all;");
    puts("");
    puts("");
    puts("entity cpu_test_tb is");
    puts("end cpu_test_tb;");
    puts("");
    puts("");
    puts("architecture TB_ARCHITECTURE of cpu_test_tb is");
    puts("");
    puts("");
    puts("");
    puts("    -- Stimulus signals - signals mapped to the input and inout ports of tested entity");
    puts("    signal  Clock    :  std_logic;");
    puts("    signal  Reset    :  std_logic;");
    puts("    signal  DataDB   :  std_logic_vector(7 downto 0);");
    puts("");
    puts("    -- Observed signals - signals mapped to the output ports of tested entity");
    puts("    signal  DataRd   :  std_logic;");
    puts("    signal  DataWr   :  std_logic;");
    puts("    signal  DataAB   :  std_logic_vector(15 downto 0);");
    puts("");
    puts("    --Signal used to stop clock signal generators");
    puts("    signal  END_SIM  :  BOOLEAN := FALSE;");
    puts("");
    puts("    -- test value types");
    puts("    type  byte_array    is array (natural range <>) of std_logic_vector(7 downto 0);");
    puts("    type  addr_array    is array (natural range <>) of std_logic_vector(15 downto 0);");


    /* finally output the test vectors */

    /* the read vector */
    puts("\n-- expected data bus write signal for each instruction");
    printf("signal  DataWrTestVals  :  std_logic_vector(0 to %d) :=\n", no_vectors - 1);
    printf("    \"");
    for (i = 0; i < no_vectors; i++)  {
        if (rdwr[i][0] == 'r')
            /* have a read signal */
            putchar('0');
        else
            /* no read signal */
            putchar('1');
    }
    printf("\";\n");

    /* then the write vector */
    puts("\n-- expected data bus read signal for each instruction");
    printf("signal  DataRdTestVals  :  std_logic_vector(0 to %d) :=\n", no_vectors - 1);

    printf("    \"");
    for (i = 0; i < no_vectors; i++)  {
        if (rdwr[i][0] == 'w')
            /* have a read signal */
            putchar('0');
        else
            /* no read signal */
            putchar('1');
    }
    printf("\";\n");

    /* next the data vectors */
    puts("\n-- supplied data bus values for each instruction (for read operations)");
    printf("signal  DataDBVals      :  byte_array(0 to %d) := (", no_vectors - 1);
    for (i = 0; i < no_vectors; i++)  {
        if ((i % VEC_PER_LINE) == 0)
            /* need a new line for vectors */
            printf("\n    ");
        /* check if have a vector */
        if (rdwr[i][0] == 'r')
            /* reading - put the data out */
            printf("X\"%s\"", data[i]);
        else
            /* not reading - high-Z */
            printf("\"ZZZZZZZZ\"");
        /* add termination based on whether last vector */
        if (i != (no_vectors - 1))  {
            if (rdwr[i][0] == 'r')
                /* reading - need comma and lots of spaces */
                printf(",      ");
            else
                /* not reading - only need comma and space */
                printf(", ");
        }
        else  {
            /* end of the vector, terminate the vector */
            puts(" );");
        }
    }

    puts("\n-- expected data bus output values for each instruction (only has a value on writes)");
    printf("signal  DataDBTestVals  :  byte_array(0 to %d) := (", no_vectors - 1);
    for (i = 0; i < no_vectors; i++)  {
        if ((i % VEC_PER_LINE) == 0)
            /* need a new line for vectors */
            printf("\n    ");
        /* check if have a vector */
        if (rdwr[i][0] == 'w')
            /* have a vector - output it for comparison */
            printf("X\"%s\"", data[i]);
        else
            /* no vector - don't do a compare */
            printf("\"--------\"");
        /* add termination based on whether last vector */
        if (i != (no_vectors - 1))  {
            if (rdwr[i][0] == 'w')
                /* writing - need comma and lots of spaces */
                printf(",      ");
            else
                /* not writing - only need comma and space */
                printf(", ");
        }
        else  {
            /* end of the vector, terminate the vector */
            puts(" );");
        }
    }

    /* finally the address vectors */
    puts("\n-- expected data addres bus values for each instruction");
    printf("signal  DataABTestVals  :  addr_array(0 to %d) := (", no_vectors - 1);
    for (i = 0; i < no_vectors; i++)  {
        if ((i % VEC_PER_LINE) == 0)
            /* need a new line for vectors */
            printf("\n    ");
        /* check if have a vector */
        if ((rdwr[i][0] == 'r') || (rdwr[i][0] == 'w'))
            /* have a vector - output it */
            printf("X\"%s\"", addr[i]);
        else
            /* no vector - don't do a compare */
            printf("\"----------------\"");
        /* add termination based on whether last vector */
        if (i != (no_vectors - 1))  {
            if ((rdwr[i][0] == 'r') || (rdwr[i][0] == 'w'))
                /* have a vector - need comma and lots of spaces */
                printf(",            ");
            else
                /* no vector - only need comma and space */
                printf(", ");
        }
        else  {
            /* end of the vector, terminate the vector */
            puts(" );");
        }
    }

    /* finish off any remaining line */
    puts("\n");


    /* done with everything - exit */
    return  0;

}
