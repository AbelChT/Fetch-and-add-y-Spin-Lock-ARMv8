//
// Created by Abel Chils Trabanco
// On 12/12/18
//

#include "mutex_spin_lock.h"

extern "C" void spin_lock(int *x);
extern "C" void spin_unlock(int *x);

mutex::mutex() : lock_variable(0) {}

void mutex::lock() {
    spin_lock(&lock_variable);
}

void mutex::unlock() {
    spin_unlock(&lock_variable);
}
