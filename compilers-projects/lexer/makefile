all:
	clear
	lex lex.l
	gcc lex.yy.c -o lexer -ll
	./lexer < test1.mjava
	./lexer < test2.mjava
