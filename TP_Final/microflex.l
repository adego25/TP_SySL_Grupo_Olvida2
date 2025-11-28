%{
#include "microbison.tab.h"     
#include <stdio.h>
#include <string.h>
extern int yylex();
%}
%option noyywrap

DIGIT   [0-9]
ID      [a-zA-Z_][a-zA-Z0-9_]*
STRING  \"[^\"]*\"

%%

"int"               { return TIPO_INT; }
"string"            { return TIPO_STRING; }
"const"             { return CONST; }

"inicio"            { return INICIO; }
"fin"               { return FIN; }
"leer"              { return LEER; }
"escribir"          { return ESCRIBIR; }

{ID}                { yylval.str = strdup(yytext); return ID; }
{DIGIT}+            { yylval.num = atoi(yytext); return NUM; }
{STRING}            { yylval.str = strdup(yytext); return STRING_LITERAL; }

":="                { return ASIGN; }
";"                 { return PYC; }
","                 { return COMA; }
"("                 { return PAR_I; }
")"                 { return PAR_D; }
"+"                 { return SUMA; }
"-"                 { return RESTA; }

[ \t\r]+            ; 

.                   { printf("token desconocido: %s\n", yytext); }

%%

