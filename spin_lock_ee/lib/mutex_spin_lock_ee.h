//
// Created by Abel Chils Trabanco
// On 12/12/18
//

#pragma once

class mutex {
private:
    int lock_variable;

public:
    mutex();

    /**
     * The calling thread locks the mutex, blocking if necessary
     */
    void lock();

    /**
     * Unlocks the mutex, releasing ownership over it.
     * If the mutex is not currently locked by the calling thread,
     * it causes undefined behavior.
     */
    void unlock();
};

