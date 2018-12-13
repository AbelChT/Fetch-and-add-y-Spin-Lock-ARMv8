//
// Created by abel on 12/13/18.
//

#include "mutex_selector.h"
#include <thread>
#include <iostream>

#define TEST_SIZE 1000000

/**
 * Number of threads to use
 */
#define NUMBER_OF_THREADS 10

using namespace std;

int variable_to_set;

mutex mtx;

void thread_race(int thread_number){
    for (int i = 0; i < TEST_SIZE; ++i) {
        mtx.lock();
        variable_to_set = thread_number;
        mtx.unlock();
    }
}

/**
 * Competition over threads to be the last in write over a variable
 * @return
 */
int main() {

    thread *thread_pool[NUMBER_OF_THREADS];

    cout << "Thread race start ..." << endl;
    clock_t begin = clock();

    /**
     * Create threads
     */
    for (unsigned int i = 0; i < NUMBER_OF_THREADS; i++) {
        thread_pool[i] = new thread(thread_race, i);
    }

    /**
     * Wait for threads and delete
     */
    for (unsigned int i = 0; i < NUMBER_OF_THREADS; i++) {
        thread_pool[i]->join();
        delete thread_pool[i];
    }

    clock_t end = clock();
    double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;

    cout << "Time taken: " << elapsed_secs << endl;

    cout << "Winner thread: " << variable_to_set << endl;

    return 0;
}
