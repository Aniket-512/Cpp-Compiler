#!/bin/sh
flex doswitch.l
yacc -d -t doswitch.y
gcc y.tab.c lex.yy.c -ly -ll
./a.out <input.txt
