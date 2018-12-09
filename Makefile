CC=arm-linux-gnueabihf-

all: main

function.o: function.s
	${CC}gcc -mcpu=cortex-a53 -c function.s -o function.o

main: main.cpp function.o
	${CC}g++ main.cpp function.o -o main
