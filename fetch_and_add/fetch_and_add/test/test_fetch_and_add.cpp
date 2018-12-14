//
// Created by Abel Chils Trabanco
// On 12/12/18
//

#include <iostream>
#include <thread>

using namespace std;
extern "C" int fetch_and_add(int *x, int add);

// Test variable
int thread_sum_counter = 0;

// Number of loop for thread
#define THREAD_NUMBER_LOOPS 100

// Number to increment in each loop
#define INCREMENT_IN_EACH_LOOP 2

void thread_test() {
    for (int i = 0; i < THREAD_NUMBER_LOOPS; ++i) {
        fetch_and_add(&thread_sum_counter, INCREMENT_IN_EACH_LOOP);
    }
}

int main() {
    cout << "Running fetch_and_add_test ..." << endl;

    // launch four threads that calls thread_test()
    thread first(thread_test);
    thread second(thread_test);
    thread third(thread_test);
    thread fourth(thread_test);

    // synchronize threads:
    first.join();                // pauses until first finishes
    second.join();               // pauses until second finishes
    third.join();                // pauses until third finishes
    fourth.join();               // pauses until fourth finishes

    cout << "Test 1: " << flush;
    if (thread_sum_counter == THREAD_NUMBER_LOOPS * INCREMENT_IN_EACH_LOOP * 4) {
        cout << "OK" << endl;
    } else {
        cout << "Fail" << endl;
        return -1;
    }

    cout << "Test 2: " << flush;

    int variable_to_increment = 4;

    int variable_to_increment_before = fetch_and_add(&variable_to_increment, 19);

    if (variable_to_increment == 23 && variable_to_increment_before == 4) {
        cout << "OK" << endl;
    } else {
        cout << "Fail" << endl;
        return -1;
    }

    return 0;
}