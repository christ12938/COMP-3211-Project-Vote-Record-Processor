MAKEFLAGS += --no-builtin-rules
CC=gcc
BIN=./bin
CFLAGS=-g
SRC=$(wildcard *.c)
TARGETS=$(SRC:%.c=%)

.PHONY: all install clean

all: precompile $(TARGETS)

precompile:
	mkdir -p bin/

main: 
	$(CC) $(CFLAGS) main.c -o $(BIN)/$@

clean:
	rm -f $(TARGETS:%=bin/%)
