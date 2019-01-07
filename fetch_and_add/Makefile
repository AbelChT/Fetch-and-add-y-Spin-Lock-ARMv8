#
# Created by Abel Chils Trabanco
#

# ARM AARCH64 compiler path
CC=/opt/gcc-arm-8.2-aarch64-linux-gnu/bin/aarch64-linux-gnu-

# ARM AARCH32 OFFICIAL RASPBIAN compiler path
# CC=/opt/raspberry-pi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-

all: test_fetch_and_add

# Fetch and add
fetch_and_add.o: fetch_and_add/aarch64/fetch_and_add.s
	${CC}gcc -c fetch_and_add/aarch64/fetch_and_add.s -o build/fetch_and_add.o

test_fetch_and_add: fetch_and_add/test/test_fetch_and_add.cpp fetch_and_add.o
	${CC}g++ -pthread fetch_and_add/test/test_fetch_and_add.cpp build/fetch_and_add.o -o build/test_fetch_and_add

clean_fetch_and_add:
	rm build/fetch_and_add.o build/test_fetch_and_add

clean: clean_fetch_and_add
