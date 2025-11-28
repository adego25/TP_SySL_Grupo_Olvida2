%{
#include <stdio.h>
#include <string.h>
#include "microbison.tab.h" /* Importante: Coincide con tu nombre de archivo Bison */

void yyerror(const char *s);
%}

%option noyywrap
%option yylineno

DIGITO      [0-9]
LETRA       [a-zA-Z]
ID          {LETRA}({LETRA}|{DIGITO}|_)*
CONST_STR   \"[^"]*\"

%%

"inicio"    { return INICIO; }
"fin"       { return FIN; }
"leer"      { return LEER; }
"escribir"  { return ESCRIBIR; }
"int"       { return TIPO_INT; }
"string"    { return TIPO_STRING; }
"const"     { return CONST; }

":="        { return ASIGNACION; }
"+"         { return SUMA; }
"-"         { return RESTA; }
"("         { return PAR_IZQ; }
")"         { return PAR_DER; }
","         { return COMA; }
";"         { return PYC; }

{DIGITO}+   { yylval.num = atoi(yytext); return CONST_INT; }
{CONST_STR} { 
              /* Eliminamos las comillas del string */
              yylval.str = strdup(yytext + 1); 
              yylval.str[strlen(yylval.str)-1] = 0;
              return CONST_LITERAL; 
            }
{ID}        { yylval.str = strdup(yytext); return ID; }

"//".*      { /* Ignorar espacios y saltos de linea */ }
[ \t\n]+    { /* Ignorar espacios y saltos de linea */ }
.           { yyerror("Caracter desconocido"); }

%%