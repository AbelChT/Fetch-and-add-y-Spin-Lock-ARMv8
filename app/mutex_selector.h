#pragma once
/**
 * Different mutex types to select
 */
#define MUTEX_NAIVE 0
#define MUTEX_SPIN_LOCK 1
#define MUTEX_SPIN_LOCK_EE 2

#ifndef SELECTED_MUTEX_TYPE
    #error "SELECTED_MUTEX_TYPE must be defined"
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_NAIVE
#include <mutex>
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK
#include "../spin_lock/lib/mutex_spin_lock.h"
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK_EE
#include "../spin_lock_ee/lib/mutex_spin_lock_ee.h"
#endif

