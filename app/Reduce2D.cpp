#include "Reduce2D.h"

using namespace std;

/**
 * Made a sum reduction over elements in v
 * v -> Vector over reduction will be done
 * n -> Number of elements of v
 */
int Reduce2D::parSum(int v[], unsigned int n) {
    mutex mutex_variable;
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
void Reduce2D::thread_sum(int v[], unsigned int n, mutex &mtx, int &global_variable) {
    for (int i = 0; i < n; ++i) {
        // Mux lock
        mtx.lock();

        global_variable = global_variable + v[i];

        // Mux unlock
        mtx.unlock();
    }
}
