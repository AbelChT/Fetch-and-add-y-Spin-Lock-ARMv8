#
# Created by Abel Chils Trabanco
#
# ARM AARCH64 compiler path
CC=/home/coki/tools/gcc-arm-aarch64-linux-gnu/bin/aarch64-linux-gnu-

# ARM AARCH32 OFFICIAL RASPBIAN compiler path
# CC=/opt/raspberry-pi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-

# COMPILER OPTIMIZATION
OPTIM=-O3

# BUILD OUTPUT SUFFIX
OUTPUT_SUFFIX=_o3_e

all: all_spin_lock all_spin_lock_ee all_spin_lock_ee_b all_naive_mutex all_none_mutex exclusive_context_change all_spin_lock_ee_b_ne

# Spin lock
spin_lock.o: spin_lock/aarch64/spin_lock.s
	${CC}gcc -c spin_lock/aarch64/spin_lock.s -o build/spin_lock.o

test_spin_lock${OUTPUT_SUFFIX}: spin_lock/test/test_spin_lock.cpp spin_lock.o
	${CC}g++ ${OPTIM} -pthread spin_lock/test/test_spin_lock.cpp build/spin_lock.o -o build/test_spin_lock${OUTPUT_SUFFIX}

spin_lock_lib${OUTPUT_SUFFIX}.o: spin_lock/lib/mutex_spin_lock.cpp
	${CC}g++ ${OPTIM} -c spin_lock/lib/mutex_spin_lock.cpp -o build/spin_lock_lib${OUTPUT_SUFFIX}.o

app_reduce_2D_spin_lock${OUTPUT_SUFFIX}: app/app.cpp app/Reduce2D.cpp spin_lock_lib${OUTPUT_SUFFIX}.o spin_lock.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK -pthread app/app.cpp app/Reduce2D.cpp build/spin_lock_lib${OUTPUT_SUFFIX}.o build/spin_lock.o -o build/app_reduce_2D_spin_lock${OUTPUT_SUFFIX}

mutex_benchmark_spin_lock_short_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp spin_lock_lib${OUTPUT_SUFFIX}.o spin_lock.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_SHORT -pthread app/mutex_benchmark.cpp build/spin_lock_lib${OUTPUT_SUFFIX}.o build/spin_lock.o -o build/mutex_benchmark_spin_lock_short_cs${OUTPUT_SUFFIX}

mutex_benchmark_spin_lock_long_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp spin_lock_lib${OUTPUT_SUFFIX}.o spin_lock.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_LONG -pthread app/mutex_benchmark.cpp build/spin_lock_lib${OUTPUT_SUFFIX}.o build/spin_lock.o -o build/mutex_benchmark_spin_lock_long_cs${OUTPUT_SUFFIX}

all_spin_lock: app_reduce_2D_spin_lock${OUTPUT_SUFFIX} test_spin_lock${OUTPUT_SUFFIX} mutex_benchmark_spin_lock_short_cs${OUTPUT_SUFFIX} mutex_benchmark_spin_lock_long_cs${OUTPUT_SUFFIX}

clean_spin_lock:
	rm build/spin_lock.o build/test_spin_lock${OUTPUT_SUFFIX} build/app_reduce_2D_spin_lock${OUTPUT_SUFFIX} build/spin_lock_lib${OUTPUT_SUFFIX}.o build/mutex_benchmark_spin_lock_short_cs${OUTPUT_SUFFIX} build/mutex_benchmark_spin_lock_long_cs${OUTPUT_SUFFIX}

# Spin lock EE
spin_lock_ee.o: spin_lock_ee/aarch64/spin_lock_ee.s
	${CC}gcc -c spin_lock_ee/aarch64/spin_lock_ee.s -o build/spin_lock_ee.o

test_spin_lock_ee${OUTPUT_SUFFIX}: spin_lock_ee/test/test_spin_lock_ee.cpp spin_lock_ee.o
	${CC}g++ ${OPTIM} -pthread spin_lock_ee/test/test_spin_lock_ee.cpp build/spin_lock_ee.o -o build/test_spin_lock_ee${OUTPUT_SUFFIX}

spin_lock_lib_ee${OUTPUT_SUFFIX}.o: spin_lock_ee/lib/mutex_spin_lock_ee.cpp
	${CC}g++ ${OPTIM} -c spin_lock_ee/lib/mutex_spin_lock_ee.cpp -o build/spin_lock_lib_ee${OUTPUT_SUFFIX}.o

app_reduce_2D_spin_lock_ee${OUTPUT_SUFFIX}: app/app.cpp app/Reduce2D.cpp spin_lock_lib_ee${OUTPUT_SUFFIX}.o spin_lock_ee.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK_EE -pthread app/app.cpp app/Reduce2D.cpp build/spin_lock_lib_ee${OUTPUT_SUFFIX}.o build/spin_lock_ee.o -o build/app_reduce_2D_spin_lock_ee${OUTPUT_SUFFIX}

mutex_benchmark_spin_lock_ee_short_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp spin_lock_lib_ee${OUTPUT_SUFFIX}.o spin_lock_ee.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK_EE -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_SHORT -pthread app/mutex_benchmark.cpp build/spin_lock_lib_ee${OUTPUT_SUFFIX}.o build/spin_lock_ee.o -o build/mutex_benchmark_spin_lock_ee_short_cs${OUTPUT_SUFFIX}

mutex_benchmark_spin_lock_ee_long_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp spin_lock_lib_ee${OUTPUT_SUFFIX}.o spin_lock_ee.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK_EE -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_LONG -pthread app/mutex_benchmark.cpp build/spin_lock_lib_ee${OUTPUT_SUFFIX}.o build/spin_lock_ee.o -o build/mutex_benchmark_spin_lock_ee_long_cs${OUTPUT_SUFFIX}

all_spin_lock_ee: app_reduce_2D_spin_lock_ee${OUTPUT_SUFFIX} test_spin_lock_ee${OUTPUT_SUFFIX} mutex_benchmark_spin_lock_ee_long_cs${OUTPUT_SUFFIX} mutex_benchmark_spin_lock_ee_short_cs${OUTPUT_SUFFIX}

clean_spin_lock_ee:
	rm build/spin_lock_ee.o build/test_spin_lock_ee${OUTPUT_SUFFIX} build/app_reduce_2D_spin_lock_ee${OUTPUT_SUFFIX} build/spin_lock_lib_ee${OUTPUT_SUFFIX}.o build/mutex_benchmark_spin_lock_ee_short_cs${OUTPUT_SUFFIX} build/mutex_benchmark_spin_lock_ee_long_cs${OUTPUT_SUFFIX}

# Spin lock EE B
spin_lock_ee_b.o: spin_lock_ee_b/aarch64/spin_lock_ee_b.s
	${CC}gcc -c spin_lock_ee_b/aarch64/spin_lock_ee_b.s -o build/spin_lock_ee_b.o

test_spin_lock_ee_b${OUTPUT_SUFFIX}: spin_lock_ee_b/test/test_spin_lock_ee_b.cpp spin_lock_ee_b.o
	${CC}g++ ${OPTIM} -pthread spin_lock_ee_b/test/test_spin_lock_ee_b.cpp build/spin_lock_ee_b.o -o build/test_spin_lock_ee_b${OUTPUT_SUFFIX}

spin_lock_lib_ee_b${OUTPUT_SUFFIX}.o: spin_lock_ee_b/lib/mutex_spin_lock_ee_b.cpp
	${CC}g++ ${OPTIM} -c spin_lock_ee_b/lib/mutex_spin_lock_ee_b.cpp -o build/spin_lock_lib_ee_b${OUTPUT_SUFFIX}.o

app_reduce_2D_spin_lock_ee_b${OUTPUT_SUFFIX}: app/app.cpp app/Reduce2D.cpp spin_lock_lib_ee_b${OUTPUT_SUFFIX}.o spin_lock_ee_b.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK_EE_B -pthread app/app.cpp app/Reduce2D.cpp build/spin_lock_lib_ee_b${OUTPUT_SUFFIX}.o build/spin_lock_ee_b.o -o build/app_reduce_2D_spin_lock_ee_b${OUTPUT_SUFFIX}

mutex_benchmark_spin_lock_ee_b_short_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp spin_lock_lib_ee_b${OUTPUT_SUFFIX}.o spin_lock_ee_b.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK_EE_B -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_SHORT -pthread app/mutex_benchmark.cpp build/spin_lock_lib_ee_b${OUTPUT_SUFFIX}.o build/spin_lock_ee_b.o -o build/mutex_benchmark_spin_lock_ee_b_short_cs${OUTPUT_SUFFIX}

mutex_benchmark_spin_lock_ee_b_long_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp spin_lock_lib_ee_b${OUTPUT_SUFFIX}.o spin_lock_ee_b.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK_EE_B -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_LONG -pthread app/mutex_benchmark.cpp build/spin_lock_lib_ee_b${OUTPUT_SUFFIX}.o build/spin_lock_ee_b.o -o build/mutex_benchmark_spin_lock_ee_b_long_cs${OUTPUT_SUFFIX}

all_spin_lock_ee_b: app_reduce_2D_spin_lock_ee_b${OUTPUT_SUFFIX} test_spin_lock_ee_b${OUTPUT_SUFFIX} mutex_benchmark_spin_lock_ee_b_long_cs${OUTPUT_SUFFIX} mutex_benchmark_spin_lock_ee_b_short_cs${OUTPUT_SUFFIX}

clean_spin_lock_ee_b:
	rm build/spin_lock_ee_b.o build/test_spin_lock_ee_b${OUTPUT_SUFFIX} build/app_reduce_2D_spin_lock_ee_b${OUTPUT_SUFFIX} build/spin_lock_lib_ee_b${OUTPUT_SUFFIX}.o build/mutex_benchmark_spin_lock_ee_b_short_cs${OUTPUT_SUFFIX} build/mutex_benchmark_spin_lock_ee_b_long_cs${OUTPUT_SUFFIX}

# Spin lock EE B NE
spin_lock_ee_b_ne.o: spin_lock_ee_b_ne/aarch64/spin_lock_ee_b_ne.s
	${CC}gcc -c spin_lock_ee_b_ne/aarch64/spin_lock_ee_b_ne.s -o build/spin_lock_ee_b_ne.o

test_spin_lock_ee_b_ne${OUTPUT_SUFFIX}: spin_lock_ee_b_ne/test/test_spin_lock_ee_b_ne.cpp spin_lock_ee_b_ne.o
	${CC}g++ ${OPTIM} -pthread spin_lock_ee_b_ne/test/test_spin_lock_ee_b_ne.cpp build/spin_lock_ee_b_ne.o -o build/test_spin_lock_ee_b_ne${OUTPUT_SUFFIX}

spin_lock_lib_ee_b_ne${OUTPUT_SUFFIX}.o: spin_lock_ee_b_ne/lib/mutex_spin_lock_ee_b_ne.cpp
	${CC}g++ ${OPTIM} -c spin_lock_ee_b_ne/lib/mutex_spin_lock_ee_b_ne.cpp -o build/spin_lock_lib_ee_b_ne${OUTPUT_SUFFIX}.o

app_reduce_2D_spin_lock_ee_b_ne${OUTPUT_SUFFIX}: app/app.cpp app/Reduce2D.cpp spin_lock_lib_ee_b_ne${OUTPUT_SUFFIX}.o spin_lock_ee_b_ne.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK_EE_B_NE -pthread app/app.cpp app/Reduce2D.cpp build/spin_lock_lib_ee_b_ne${OUTPUT_SUFFIX}.o build/spin_lock_ee_b_ne.o -o build/app_reduce_2D_spin_lock_ee_b_ne${OUTPUT_SUFFIX}

mutex_benchmark_spin_lock_ee_b_ne_short_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp spin_lock_lib_ee_b_ne${OUTPUT_SUFFIX}.o spin_lock_ee_b_ne.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK_EE_B_NE -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_SHORT -pthread app/mutex_benchmark.cpp build/spin_lock_lib_ee_b_ne${OUTPUT_SUFFIX}.o build/spin_lock_ee_b_ne.o -o build/mutex_benchmark_spin_lock_ee_b_ne_short_cs${OUTPUT_SUFFIX}

mutex_benchmark_spin_lock_ee_b_ne_long_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp spin_lock_lib_ee_b_ne${OUTPUT_SUFFIX}.o spin_lock_ee_b_ne.o
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_SPIN_LOCK_EE_B_NE -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_LONG -pthread app/mutex_benchmark.cpp build/spin_lock_lib_ee_b_ne${OUTPUT_SUFFIX}.o build/spin_lock_ee_b_ne.o -o build/mutex_benchmark_spin_lock_ee_b_ne_long_cs${OUTPUT_SUFFIX}

all_spin_lock_ee_b_ne: app_reduce_2D_spin_lock_ee_b_ne${OUTPUT_SUFFIX} test_spin_lock_ee_b_ne${OUTPUT_SUFFIX} mutex_benchmark_spin_lock_ee_b_ne_long_cs${OUTPUT_SUFFIX} mutex_benchmark_spin_lock_ee_b_ne_short_cs${OUTPUT_SUFFIX}

clean_spin_lock_ee_b_ne:
	rm build/spin_lock_ee_b_ne.o build/test_spin_lock_ee_b_ne${OUTPUT_SUFFIX} build/app_reduce_2D_spin_lock_ee_b_ne${OUTPUT_SUFFIX} build/spin_lock_lib_ee_b_ne${OUTPUT_SUFFIX}.o build/mutex_benchmark_spin_lock_ee_b_ne_long_cs${OUTPUT_SUFFIX} build/mutex_benchmark_spin_lock_ee_b_ne_short_cs${OUTPUT_SUFFIX}

# Naive mutex
app_reduce_2D_naive_mutex${OUTPUT_SUFFIX}: app/app.cpp app/Reduce2D.cpp
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_NAIVE -pthread app/app.cpp app/Reduce2D.cpp -o build/app_reduce_2D_naive_mutex${OUTPUT_SUFFIX}

mutex_benchmark_naive_mutex_short_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_NAIVE -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_SHORT -pthread app/mutex_benchmark.cpp -o build/mutex_benchmark_naive_mutex_short_cs${OUTPUT_SUFFIX}

mutex_benchmark_naive_mutex_long_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp
	${CC}g++ ${OPTIM} -DSELECTED_MUTEX_TYPE=MUTEX_NAIVE -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_LONG -pthread app/mutex_benchmark.cpp -o build/mutex_benchmark_naive_mutex_long_cs${OUTPUT_SUFFIX}

all_naive_mutex: app_reduce_2D_naive_mutex${OUTPUT_SUFFIX} mutex_benchmark_naive_mutex_long_cs${OUTPUT_SUFFIX} mutex_benchmark_naive_mutex_short_cs${OUTPUT_SUFFIX}

clean_naive_mutex:
	rm build/app_reduce_2D_naive_mutex${OUTPUT_SUFFIX} build/mutex_benchmark_naive_mutex_long_cs${OUTPUT_SUFFIX} build/mutex_benchmark_naive_mutex_short_cs${OUTPUT_SUFFIX}

# No mutex
mutex_benchmark_none_mutex_short_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp
	${CC}g++ -DSELECTED_MUTEX_TYPE=MUTEX_NONE -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_SHORT -pthread app/mutex_benchmark.cpp -o build/mutex_benchmark_none_mutex_short_cs${OUTPUT_SUFFIX}

mutex_benchmark_none_mutex_long_cs${OUTPUT_SUFFIX}: app/mutex_benchmark.cpp
	${CC}g++ -DSELECTED_MUTEX_TYPE=MUTEX_NONE -DSELECTED_CRITICAL_SECTION=CRITICAL_SECTION_LONG -pthread app/mutex_benchmark.cpp -o build/mutex_benchmark_none_mutex_long_cs${OUTPUT_SUFFIX}

clean_none_mutex:
	rm build/mutex_benchmark_none_mutex_long_cs${OUTPUT_SUFFIX} build/mutex_benchmark_none_mutex_short_cs${OUTPUT_SUFFIX}

all_none_mutex: mutex_benchmark_none_mutex_short_cs${OUTPUT_SUFFIX} mutex_benchmark_none_mutex_long_cs${OUTPUT_SUFFIX}

# Misc
exclusive_context_change:
	${CC}g++  misc/exclusive_context_change.cpp misc/read_store_exclusive.s -o build/exclusive_context_change

clean_exclusive_context_change:
	rm build/exclusive_context_change

clean: clean_spin_lock clean_spin_lock_ee clean_naive_mutex clean_exclusive_context_change clean_none_mutex clean_spin_lock_ee_b clean_spin_lock_ee_b_ne
