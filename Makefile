CC = gcc
LEX = flex
YACC = bison
CFLAGS = -Wall -Wextra -std=gnu11

TARGET = mini_compiler

all: $(TARGET)

parser.tab.c parser.tab.h: parser.y
	$(YACC) -d -Wall parser.y

lex.yy.c: lexer.l parser.tab.h
	$(LEX) lexer.l

$(TARGET): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) parser.tab.c lex.yy.c -o $(TARGET)

test: $(TARGET)
	@printf "int x;\nx = 10 + 5 * 2;\nprint(x);\n" | ./$(TARGET) | grep -qx "20"
	@echo "Targeted test passed"

clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h lex.yy.c

.PHONY: all test clean
