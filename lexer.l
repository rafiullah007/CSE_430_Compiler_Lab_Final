%option noyywrap yylineno

%{
#include "parser.tab.h"
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%%

"int"                    { return INT; }
"print"                  { return PRINT; }

[0-9]+                   {
                            yylval.num = atoi(yytext);
                            return NUMBER;
                         }

[a-zA-Z_][a-zA-Z0-9_]*   {
                            yylval.id = xstrdup(yytext);
                            if (yylval.id == NULL) {
                                fprintf(stderr, "Error: out of memory.\n");
                                exit(EXIT_FAILURE);
                            }
                            return IDENTIFIER;
                         }

[ \t\r]+                 { /* ignore whitespace */ }
\n                       { /* yylineno is updated by flex */ }

"//".*                  { /* ignore line comments */ }

[+\-*/=();]              { return yytext[0]; }

.                        {
                            fprintf(stderr, "Unexpected character '%s' at line %d\n", yytext, yylineno);
                            return yytext[0];
                         }

%%
