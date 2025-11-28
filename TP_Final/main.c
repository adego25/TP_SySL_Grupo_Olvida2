#include <stdio.h>

int yyparse(void);

int main() {
    printf("test de main para q deje de tirar error el makefile\n");
    int res = yyparse();
    printf("Terminado con codigo: %d\n", res);
    return 0;
}
