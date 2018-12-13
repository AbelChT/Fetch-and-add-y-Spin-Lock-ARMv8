//
// Created by Abel Chils Trabanco
// On 12/12/18
//

#include "mutex_spin_lock_ee_b.h"

extern "C" void spin_lock_ee_b(char *x);
extern "C" void spin_unlock_ee_b(char *x);

mutex::mutex() : lock_variable(0) {}

void mutex::lock() {
    spin_lock_ee_b(&lock_variable);
}

void mutex::unlock() {
    spin_unlock_ee_b(&lock_variable);
}
