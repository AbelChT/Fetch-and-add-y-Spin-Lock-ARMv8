#include <iostream>
#include <thread>         // std::thread
#include <chrono>         // std::chrono::seconds

using namespace std;
extern "C" void spin_lock(int *x);
extern "C" void spin_unlock(int *x);

// Variable for spin lock
int lock_for_mutex = 0;

// Test variable (Count the number of threads)
int thread_counter = 0;

void thread_test()
{
    // Local copy of thread counter
    int thread_counter_local;
    
    spin_lock(&lock_for_mutex);

    thread_counter_local = thread_counter;

    this_thread::sleep_for (chrono::seconds(1));

    thread_counter = thread_counter_local + 1;

    spin_unlock(&lock_for_mutex);
}

int main() {
    cout << "Running spin_lock_test ( Wait for 2 seconds ) ..." << endl;

    // launch two threads that calls thread_test()
    thread first (thread_test);
    thread second (thread_test);

    // synchronize threads:
    first.join();                // pauses until first finishes
    second.join();               // pauses until second finishes

    cout << "Test: " << flush;
    if(thread_counter == 2){
        cout << "OK" << endl;
        return 0;
    }else{
        cout << "Fail" << endl;
        return -1;
    }
}