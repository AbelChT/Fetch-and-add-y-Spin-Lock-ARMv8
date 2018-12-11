# ARM AARCH64 compiler path
CC=/opt/gcc-arm-8.2-aarch64-linux-gnu/bin/aarch64-linux-gnu-

# ARM AARCH32 OFFICIAL RASPBIAN compiler path
# CC=/opt/raspberry-pi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-

all: test_spin_lock

spin_lock.o: spin_lock/aarch64/spin_lock.s
	${CC}gcc -c spin_lock/aarch64/spin_lock.s -o build/spin_lock.o

test_spin_lock: spin_lock/test/test_spin_lock.cpp spin_lock.o
	${CC}g++ -pthread spin_lock/test/test_spin_lock.cpp build/spin_lock.o -o build/test_spin_lock

clean_spin_lock:
	rm build/spin_lock.o build/test_spin_lock

clean: clean_spin_lock
