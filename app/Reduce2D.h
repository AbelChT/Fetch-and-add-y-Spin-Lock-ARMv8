#pragma once

#include <thread>

using namespace std;

/**
 * Different mutex types to select
 */
#define MUTEX_NAIVE 0
#define MUTEX_SPIN_LOCK 1
#define MUTEX_SPIN_LOCK_EE 2

#define SELECTED_MUTEX_TYPE MUTEX_NAIVE

/**
 * WARNING: This class is created for evaluate diferent mutex implementation performance.
 * You should't use it for other reason indeed.
 * This class intentionally do the partials reduce in a global variable instead of in a local
 * one and don't use the array recommended class neither.
 *
 * The functions of every instance of this class must be called from a single thread.
 */


/**
 * Number of threads to use
 */
#define NUMBER_OF_THREADS 10

class Reduce2D {
private:
    /**
     * n -> number of elements to process by the thread
     */
    static void thread_sum(int v[], unsigned int n, int &mutex_variable, int &global_variable);

public:
    /**
    * Made a sum reduction over elements in v
    * v -> Vector over reduction will be done
    * n -> Number of elements of v
    */
    static int parSum(int v[], unsigned int n);
};
