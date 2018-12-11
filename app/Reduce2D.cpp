#include "Reduce2D.h"

#if SELECTED_MUTEX_TYPE == MUTEX_NAIVE

#include <mutex>

#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK
extern "C" void spin_lock(int *x);
extern "C" void spin_unlock(int *x);
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK_EE
extern "C" void spin_lock_ee(int *x);
extern "C" void spin_unlock_ee(int *x);
#endif

using namespace std;

#if SELECTED_MUTEX_TYPE == MUTEX_NAIVE
static mutex mtx;           // mutex for critical section
#endif

/**
 * Made a sum reduction over elements in v
 * v -> Vector over reduction will be done
 * n -> Number of elements of v
 */
int Reduce2D::parSum(int v[], unsigned int n) {
    int mutex_variable = 0;
    int global_result = 0;
    thread *thread_pool[NUMBER_OF_THREADS];

    unsigned int work_for_thread[NUMBER_OF_THREADS];

    unsigned int thread_start_position[NUMBER_OF_THREADS];

    unsigned int work_left = n;

    /**
     * Calculate the work for every thread
     */
    for (unsigned int i = NUMBER_OF_THREADS; i >= 1; i--) {
        work_for_thread[i - 1] = work_left / i;
        work_left = work_left - (work_left / i);
        thread_start_position[i - 1] = work_left;
    }


    /**
     * Create threads
     */
    for (unsigned int i = 0; i < NUMBER_OF_THREADS; i++) {
        thread_pool[i] = new thread(thread_sum, &v[thread_start_position[i]], work_for_thread[i],
                                    ref(mutex_variable), ref(global_result));
    }

    /**
     * Wait for threads and delete
     */
    for (unsigned int i = 0; i < NUMBER_OF_THREADS; i++) {
        thread_pool[i]->join();
        delete thread_pool[i];
    }

    return global_result;
}

/**
 * n -> number of elements to process by the thread
 */
void Reduce2D::thread_sum(int v[], unsigned int n, int &mutex_variable, int &global_variable) {
    for (int i = 0; i < n; ++i) {
        // Mux lock
#if SELECTED_MUTEX_TYPE == MUTEX_NAIVE
        mtx.lock();
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK
        spin_lock(&mutex_variable);
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK_EE
        spin_lock_ee(&mutex_variable);
#endif


        global_variable = global_variable + v[i];
        // Mux unlock
#if SELECTED_MUTEX_TYPE == MUTEX_NAIVE
        mtx.unlock();
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK
        spin_unlock(&mutex_variable);
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK_EE
        spin_unlock_ee(&mutex_variable);
#endif
    }
}
