//
// Created by abel on 09/01/19.
//

#include "mutex_selector.h"
#include <thread>
#include <iostream>

/**
 * Number of threads to use
 */
#define NUMBER_OF_THREADS 10

using namespace std;

mutex mtx;

/**
 * Critical section types
 */
#define CRITICAL_SECTION_SHORT 0
#define CRITICAL_SECTION_LONG 1

#ifndef SELECTED_CRITICAL_SECTION
#error "SELECTED_CRITICAL_SECTION must be defined"
#endif

#if SELECTED_CRITICAL_SECTION == CRITICAL_SECTION_SHORT
#define TEST_SIZE 1000000
int variable_to_set;
void __attribute__((optimize("O0"))) critical_section(int thread_number){
    variable_to_set = thread_number;
}
#endif

#if SELECTED_CRITICAL_SECTION == CRITICAL_SECTION_LONG
#define TEST_SIZE 10000
#define SIZE_OVERHEAD_LOOP 3000
int variable_to_set;
void __attribute__((optimize("O0"))) critical_section(int thread_number){
    for(int j = 0; j < SIZE_OVERHEAD_LOOP; ++j){
        variable_to_set = thread_number;
    }
}
#endif

/**
 * Work that every thread do
 */
void thread_work(int thread_number){
    for (int i = 0; i < TEST_SIZE; ++i) {
        mtx.lock();
        critical_section(thread_number);
        mtx.unlock();
    }
}

/**
 * Competition over threads to be the last in write over a variable
 * @return
 */
int main() {
    thread *thread_pool[NUMBER_OF_THREADS];

    //cout << "Thread race start ..." << endl;
    clock_t begin = clock();

    /**
     * Create threads
     */
    for (unsigned int i = 0; i < NUMBER_OF_THREADS; i++) {
        thread_pool[i] = new thread(thread_work, i);
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

    //cout << "Time taken: " << elapsed_secs << endl;
    
    cout << elapsed_secs << endl;

    //cout << "Winner thread: " << variable_to_set << endl;

    return 0;
}
