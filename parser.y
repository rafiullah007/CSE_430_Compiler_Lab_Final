%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "common.h"

int yylex(void);
void yyerror(const char *s);

#define MAX_SYMBOLS 256

typedef struct {
    char *name;
    int value;
    int initialized;
} Symbol;

static Symbol symbols[MAX_SYMBOLS];
static int symbol_count = 0;

static int find_symbol(const char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbols[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

static void declare_variable(const char *name) {
    if (find_symbol(name) != -1) {
        fprintf(stderr, "Error: variable '%s' is already declared.\n", name);
        exit(EXIT_FAILURE);
    }

    if (symbol_count >= MAX_SYMBOLS) {
        fprintf(stderr, "Error: symbol table overflow.\n");
        exit(EXIT_FAILURE);
    }

    symbols[symbol_count].name = xstrdup(name);
    if (symbols[symbol_count].name == NULL) {
        fprintf(stderr, "Error: memory allocation failed while declaring '%s'.\n", name);
        exit(EXIT_FAILURE);
    }

    symbols[symbol_count].value = 0;
    symbols[symbol_count].initialized = 0;
    symbol_count++;
}

static void set_variable(const char *name, int value) {
    int index = find_symbol(name);
    if (index == -1) {
        fprintf(stderr, "Error: variable '%s' is not declared.\n", name);
        exit(EXIT_FAILURE);
    }

    symbols[index].value = value;
    symbols[index].initialized = 1;
}

static int get_variable(const char *name) {
    int index = find_symbol(name);
    if (index == -1) {
        fprintf(stderr, "Error: variable '%s' is not declared.\n", name);
        exit(EXIT_FAILURE);
    }

    if (!symbols[index].initialized) {
        fprintf(stderr, "Error: variable '%s' is not initialized.\n", name);
        exit(EXIT_FAILURE);
    }

    return symbols[index].value;
}

static void free_symbols(void) {
    for (int i = 0; i < symbol_count; i++) {
        free(symbols[i].name);
        symbols[i].name = NULL;
    }
}

extern int yylineno;
%}

%union {
    int num;
    char *id;
}

%token <num> NUMBER
%token <id> IDENTIFIER
%token INT PRINT

%type <num> expression

%left '+' '-'
%left '*' '/'
%precedence UMINUS

%%

program:
    statements
    ;

statements:
      %empty
    | statements statement
    ;

statement:
      INT IDENTIFIER ';' {
          declare_variable($2);
          free($2);
      }
    | IDENTIFIER '=' expression ';' {
          set_variable($1, $3);
          free($1);
      }
    | PRINT '(' expression ')' ';' {
          printf("%d\n", $3);
      }
    ;

expression:
      NUMBER { $$ = $1; }
    | IDENTIFIER {
          $$ = get_variable($1);
          free($1);
      }
    | expression '+' expression { $$ = $1 + $3; }
    | expression '-' expression { $$ = $1 - $3; }
    | expression '*' expression { $$ = $1 * $3; }
    | expression '/' expression {
          if ($3 == 0) {
              fprintf(stderr, "Error: division by zero.\n");
              exit(EXIT_FAILURE);
          }
          $$ = $1 / $3;
      }
    | '(' expression ')' { $$ = $2; }
    | '-' expression %prec UMINUS { $$ = -$2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, s);
}

int main(void) {
    int result = yyparse();
    free_symbols();
    return result;
}
