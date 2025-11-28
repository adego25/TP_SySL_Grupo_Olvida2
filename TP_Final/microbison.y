%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
void yyerror(const char *s);

typedef struct {
    char nombre[64];
    char valor[512];
} Var;

Var tabla[100];
int cantVars = 0;

Var* buscarVar(char* n){
    for(int i=0;i<cantVars;i++){
        if(strcmp(tabla[i].nombre, n)==0) return &tabla[i];
    }
    return NULL;
}

Var* crearVar(char* n){
    Var* v = &tabla[cantVars++];
    strcpy(v->nombre, n);
    v->valor[0] = 0;
    return v;
}
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
%type <str> strexpr

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
        { 
            Var* v = buscarVar($1);
            if (!v) v = crearVar($1);
            sprintf(v->valor, "%d", $3);
            printf("asign num: %s = %s\n", $1, v->valor);
        }

    | ID ASIGN strexpr PYC
        {
            Var* v = buscarVar($1);
            if (!v) v = crearVar($1);
            strcpy(v->valor, $3);
            printf("asign str: %s = %s\n", $1, v->valor);
            free($3);
        }

    | LEER PAR_I listaIdentificadores PAR_D PYC
        { printf("leer\n"); }

    | ESCRIBIR PAR_I strexpr PAR_D PYC
          {
            char* s = $3;

            if (s[0]=='"' && s[strlen(s)-1]=='"') {
                s[strlen(s)-1] = 0;
                printf("%s\n", s+1);
            } else {
                printf("%s\n", s);
            }

            free(s);
        }

    | TIPO_INT ID PYC
        {
            Var* v = buscarVar($2);
            if (!v) v = crearVar($2);
            printf("decl int %s\n", $2);
        }

    | TIPO_STRING ID PYC
        {
            Var* v = buscarVar($2);
            if (!v) v = crearVar($2);
            printf("decl string %s\n", $2);
        }

    | CONST TIPO_INT ID ASIGN expresion PYC
        {
            Var* v = buscarVar($3);
            if (!v) v = crearVar($3);
            sprintf(v->valor, "%d", $5);
            printf("const int %s = %d\n", $3, $5);
        }
    ;

listaIdentificadores:
      ID
    | listaIdentificadores COMA ID
    ;

strexpr:
      STRING_LITERAL
        { $$ = strdup($1); }

    | PAR_I strexpr PAR_D
        { $$ = $2; }

    | strexpr strexpr
        { 
            char* tmp = malloc(strlen($1)+strlen($2)+1);
            strcpy(tmp, $1);
            strcat(tmp, $2);
            free($1);
            free($2);
            $$ = tmp;
        }

    | LEER PAR_I PAR_D
        {
            char buffer[256];
            printf("ingrese texto: ");
            scanf(" %255[^\n]", buffer);
            $$ = strdup(buffer);
        }

    | ID
        {
            Var* v = buscarVar($1);
            if (!v) $$ = strdup("");
            else $$ = strdup(v->valor);
        }
    ;

expresion:
      primaria
    | expresion SUMA primaria   { $$ = $1 + $3; }
    | expresion RESTA primaria  { $$ = $1 - $3; }
    ;

primaria:
      ID
        { 
            Var* v = buscarVar($1);
            if (!v) $$ = 0;
            else $$ = atoi(v->valor);
        }

    | NUM
        { $$ = $1; }

    | PAR_I expresion PAR_D
        { $$ = $2; }
    ;

%%

void yyerror(const char *s){
    printf("Error: %s\n", s);
}
