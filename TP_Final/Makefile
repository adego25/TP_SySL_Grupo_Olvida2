micro: microbison.y microflex.l main.c
	bison -d microbison.y
	flex microflex.l
	gcc lex.yy.c microbison.tab.c main.c -o micro

clean:
	rm -f lex.yy.c microbison.tab.c microbison.tab.h micro
