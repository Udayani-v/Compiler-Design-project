lex 1.l
yacc -d 1.y
gcc lex.yy.c y.tab.c -ll

