# ARM AARCH64 compiler path
CC=/opt/gcc-arm-8.2-aarch64-linux-gnu/bin/aarch64-linux-gnu-

# ARM AARCH32 OFFICIAL RASPBIAN compiler path
# CC=/opt/raspberry-pi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-

all: test_spin_lock test_fetch_and_add test_spin_lock_ee app_reduce_2D_spin_lock app_reduce_2D_spin_lock_ee app_reduce_2D_naive_mutex exclusive_context_change

# Spin lock
spin_lock.o: spin_lock/aarch64/spin_lock.s
	${CC}gcc -c spin_lock/aarch64/spin_lock.s -o build/spin_lock.o

test_spin_lock: spin_lock/test/test_spin_lock.cpp spin_lock.o
	${CC}g++ -pthread spin_lock/test/test_spin_lock.cpp build/spin_lock.o -o build/test_spin_lock

spin_lock_lib.o: spin_lock/lib/mutex_spin_lock.cpp
	${CC}g++ -c spin_lock/lib/mutex_spin_lock.cpp -o build/spin_lock_lib.o

app_reduce_2D_spin_lock: app/app.cpp app/Reduce2D.cpp spin_lock_lib.o spin_lock.o
	${CC}g++ -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK -pthread app/app.cpp app/Reduce2D.cpp build/spin_lock_lib.o build/spin_lock.o -o build/app_reduce_2D_spin_lock

clean_spin_lock:
	rm build/spin_lock.o build/test_spin_lock build/app_reduce_2D_spin_lock build/spin_lock_lib.o

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

spin_lock_lib_ee.o: spin_lock_ee/lib/mutex_spin_lock_ee.cpp
	${CC}g++ -c spin_lock_ee/lib/mutex_spin_lock_ee.cpp -o build/spin_lock_lib_ee.o

app_reduce_2D_spin_lock_ee: app/app.cpp app/Reduce2D.cpp spin_lock_lib_ee.o spin_lock_ee.o
	${CC}g++ -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK_EE -pthread app/app.cpp app/Reduce2D.cpp build/spin_lock_lib_ee.o build/spin_lock_ee.o -o build/app_reduce_2D_spin_lock_ee

clean_spin_lock_ee:
	rm build/spin_lock_ee.o build/test_spin_lock_ee build/app_reduce_2D_spin_lock_ee build/spin_lock_lib_ee.o

# Naive mutex
app_reduce_2D_naive_mutex: app/app.cpp app/Reduce2D.cpp
	${CC}g++ -DSELECTED_MUTEX_TYPE=MUTEX_NAIVE -pthread app/app.cpp app/Reduce2D.cpp -o build/app_reduce_2D_naive_mutex

clean_reduce_2D_naive_mutex:
	rm build/app_reduce_2D_naive_mutex

# Misc
exclusive_context_change:
	${CC}g++  misc/exclusive_context_change.cpp misc/read_store_exclusive.s -o build/exclusive_context_change

clean_exclusive_context_change:
	rm build/exclusive_context_change

clean: clean_spin_lock clean_fetch_and_add clean_spin_lock_ee clean_reduce_2D_naive_mutex clean_exclusive_context_change
