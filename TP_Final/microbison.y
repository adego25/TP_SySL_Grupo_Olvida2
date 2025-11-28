%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern FILE *yyin;
void yyerror(const char *s);

/* --- ESTRUCTURAS DE LA TABLA DE SIMBOLOS --- */
typedef enum { ENTERO, CADENA } TipoDato;

typedef struct {
    char nombre[32];
    TipoDato tipo;
    int valorInt;
    char valorStr[256];
    int esConstante;
} Simbolo;

Simbolo tabla[100];
int cantSimbolos = 0;

/* --- FUNCIONES AUXILIARES --- */
Simbolo* buscar(char* nombre) {
    for(int i=0; i<cantSimbolos; i++) {
        if(strcmp(tabla[i].nombre, nombre) == 0) return &tabla[i];
    }
    return NULL;
}

void instalar(char* nombre, TipoDato tipo, int esConst) {
    if(buscar(nombre) != NULL) {
        char buffer[100];
        sprintf(buffer, "Error semantico: La variable '%s' ya fue declarada.", nombre);
        yyerror(buffer);
        return; 
    }
    Simbolo* s = &tabla[cantSimbolos++];
    strcpy(s->nombre, nombre);
    s->tipo = tipo;
    s->esConstante = esConst;
}

void asignarInt(char* nombre, int valor) {
    Simbolo* s = buscar(nombre);
    if(s == NULL) {
        yyerror("Error semantico: Variable no declarada.");
    } else if (s->esConstante) {
        yyerror("Error semantico: No se puede asignar a una constante.");
    } else if (s->tipo != ENTERO) {
        yyerror("Error semantico: Tipo incompatible, se esperaba entero.");
    } else {
        s->valorInt = valor;
    }
}

void asignarStr(char* nombre, char* valor) {
    Simbolo* s = buscar(nombre);
    if(s == NULL) {
        yyerror("Error semantico: Variable no declarada.");
    } else if (s->esConstante) {
        yyerror("Error semantico: No se puede asignar a una constante.");
    } else if (s->tipo != CADENA) {
        yyerror("Error semantico: Tipo incompatible, se esperaba string.");
    } else {
        if (strlen(valor) > 255) {
            yyerror("Error: String excede 255 caracteres.");
        }
        strncpy(s->valorStr, valor, 255);
    }
}

void leer(char* nombre) {
    Simbolo* s = buscar(nombre);
    if(!s) { yyerror("Error: Variable no declarada en leer()."); return; }
    
    printf("Ingrese valor para %s: ", nombre);
    if(s->tipo == ENTERO) {
        scanf("%d", &s->valorInt);
    } else {
        char buffer[1024];
        scanf("%s", buffer); 
        strncpy(s->valorStr, buffer, 255);
    }
}

%}

%union {
    int num;
    char* str;
}

%token INICIO FIN LEER ESCRIBIR TIPO_INT TIPO_STRING CONST
%token ASIGNACION SUMA RESTA PAR_IZQ PAR_DER COMA PYC
%token <num> CONST_INT
%token <str> CONST_LITERAL ID

%type <num> expresion primaria_int
%type <str> expresion_str

%%

objetivo: programa { printf("\n>> Compilacion y ejecucion finalizada con exito.\n"); };

programa: INICIO listaSentencias FIN;

listaSentencias: sentencia | sentencia listaSentencias;

sentencia: 
      declaracion
    | asignacion
    | entrada
    | salida
    ;

declaracion:
      TIPO_INT ID PYC { instalar($2, ENTERO, 0); free($2); }
    | TIPO_STRING ID PYC { instalar($2, CADENA, 0); free($2); }
    | CONST TIPO_INT ID ASIGNACION CONST_INT PYC { 
          instalar($3, ENTERO, 1);
          Simbolo* s = buscar($3);
          if(s) s->valorInt = $5;
          free($3);
      }
    ;

asignacion:
      ID ASIGNACION expresion PYC { asignarInt($1, $3); free($1); }
    | ID ASIGNACION expresion_str PYC { asignarStr($1, $3); free($1); free($3); }
    ;

entrada:
      LEER PAR_IZQ listaIdentificadores PAR_DER PYC
    ;

listaIdentificadores:
      ID { leer($1); free($1); }
    | ID COMA listaIdentificadores { leer($1); free($1); }
    ;

salida:
      ESCRIBIR PAR_IZQ listaExpresiones PAR_DER PYC
    ;

listaExpresiones:
      expresionGen
    | expresionGen COMA listaExpresiones
    ;

expresionGen:
      expresion { printf("%d", $1); }
    | expresion_str { printf("%s", $1); free($1); }
    ;

expresion:
      primaria_int
    | expresion SUMA primaria_int { $$ = $1 + $3; }
    | expresion RESTA primaria_int { $$ = $1 - $3; }
    ;

primaria_int:
      ID { 
          Simbolo* s = buscar($1);
          if(!s) { yyerror("Variable no declarada."); $$ = 0; }
          else if(s->tipo != ENTERO) { yyerror("Error de tipo."); $$=0; }
          else $$ = s->valorInt;
          free($1);
      }
    | CONST_INT { $$ = $1; }
    | PAR_IZQ expresion PAR_DER { $$ = $2; }
    ;

expresion_str:
    CONST_LITERAL { $$ = $1; }
    | ID {
        Simbolo* s = buscar($1);
        if(!s) { yyerror("Variable no declarada."); $$ = strdup(""); }
        else if(s->tipo != CADENA) { yyerror("Error de tipo."); $$ = strdup(""); }
        else $$ = strdup(s->valorStr);
        free($1);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Linea %d: %s\n", yylineno, s);
    exit(1);
}

int main(int argc, char** argv) {
    printf("MICRO INTERPRETE\n");
    printf("1. Teclado\n2. Archivo\nOpcion: ");
    int op;
    scanf("%d", &op);
    if (op == 2) {
        char filename[100];
        printf("Archivo: ");
        scanf("%s", filename);
        yyin = fopen(filename, "r");
        if (!yyin) { perror("Error"); return 1; }
    }
    yyparse();
    return 0;
}