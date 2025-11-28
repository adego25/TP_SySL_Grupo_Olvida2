%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
void yyerror(const char *s);

%}

%union {
    int num;
    char* str;
}

%token TIPO_INT TIPO_STRING
%token CONST
%token INICIO FIN
%token LEER ESCRIBIR
%token <str> ID
%token <num> NUM
%token <str> STRING_LITERAL

%token ASIGN
%token SUMA RESTA
%token PYC
%token COMA
%token PAR_I PAR_D

%type <num> expresion primaria

%%

objetivo:
      programa
      { printf("ok\n"); }
    ;

programa:
      INICIO listaSentencias FIN
    ;

listaSentencias:
      sentencia
    | listaSentencias sentencia
    ;

sentencia:
      ID ASIGN expresion PYC
        { printf("asign: %s = %d\n", $1, $3); }
    | LEER PAR_I listaIdentificadores PAR_D PYC
        { printf("leer\n"); }
    | ESCRIBIR PAR_I listaExpresiones PAR_D PYC
        { printf("escribir\n"); }
    | TIPO_INT ID PYC
        { printf("decl int %s\n", $2); }
    | TIPO_STRING ID PYC
        { printf("decl string %s\n", $2); }
    | CONST TIPO_INT ID ASIGN expresion PYC
        { printf("const int %s = %d\n", $3, $5); }
    ;

listaIdentificadores:
      ID
    | listaIdentificadores COMA ID
    ;

listaExpresiones:
      expresion
    | listaExpresiones COMA expresion
    ;

expresion:
      primaria
    | expresion SUMA primaria   { $$ = $1 + $3; }
    | expresion RESTA primaria  { $$ = $1 - $3; }
    ;

primaria:
      ID               { /*buscar en tabla (por ahora 0) */ $$ = 0; }
    | NUM              { $$ = $1; }
    | PAR_I expresion PAR_D { $$ = $2; }
    ;

%%

void yyerror(const char *s){
    printf("Error: %s\n", s);
}
