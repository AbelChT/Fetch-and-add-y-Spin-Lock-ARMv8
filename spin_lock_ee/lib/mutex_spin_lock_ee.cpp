#include "mutex_spin_lock_ee.h"

extern "C" void spin_lock_ee(int *x);
extern "C" void spin_unlock_ee(int *x);

mutex::mutex() : lock_variable(0) {}

void mutex::lock() {
    spin_lock_ee(&lock_variable);
}

void mutex::unlock() {
    spin_unlock_ee(&lock_variable);
}
