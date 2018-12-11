# ARM AARCH64 compiler path
CC=/opt/gcc-arm-8.2-aarch64-linux-gnu/bin/aarch64-linux-gnu-

# ARM AARCH32 OFFICIAL RASPBIAN compiler path
# CC=/opt/raspberry-pi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-

all: test_spin_lock test_fetch_and_add test_spin_lock_ee

# Spin lock
spin_lock.o: spin_lock/aarch64/spin_lock.s
	${CC}gcc -c spin_lock/aarch64/spin_lock.s -o build/spin_lock.o

test_spin_lock: spin_lock/test/test_spin_lock.cpp spin_lock.o
	${CC}g++ -pthread spin_lock/test/test_spin_lock.cpp build/spin_lock.o -o build/test_spin_lock

clean_spin_lock:
	rm build/spin_lock.o build/test_spin_lock

# Fetch and add
fetch_and_add.o: fetch_and_add/aarch64/fetch_and_add.s
	${CC}gcc -c fetch_and_add/aarch64/fetch_and_add.s -o build/fetch_and_add.o

test_fetch_and_add: fetch_and_add/test/test_fetch_and_add.cpp fetch_and_add.o
	${CC}g++ -pthread fetch_and_add/test/test_fetch_and_add.cpp build/fetch_and_add.o -o build/test_fetch_and_add

clean_fetch_and_add:
	rm build/fetch_and_add.o build/test_fetch_and_add

# Spin lock EE
spin_lock_ee.o: spin_lock_ee/aarch64/spin_lock_ee.s
	${CC}gcc -c spin_lock_ee/aarch64/spin_lock_ee.s -o build/spin_lock_ee.o

test_spin_lock_ee: spin_lock_ee/test/test_spin_lock_ee.cpp spin_lock_ee.o
	${CC}g++ -pthread spin_lock_ee/test/test_spin_lock_ee.cpp build/spin_lock_ee.o -o build/test_spin_lock_ee

clean_spin_lock_ee:
	rm build/spin_lock_ee.o build/test_spin_lock_ee

clean: clean_spin_lock clean_fetch_and_add clean_spin_lock_ee
