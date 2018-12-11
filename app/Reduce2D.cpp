#include <thread>
using namespace std;

/**
 * WARNING: This class is created for evaluate diferent mutex implementation performance.
 * You should't use it for other reason indeed.
 * This class intentionally do the partials reduce in a global variable instead of in a local
 * one and don't use the array recommended class neither.
 * 
 * The functions of every instance of this class must be called from a single thread.
 */
class Reduce2D{
    #define NUMBER_OF_THREADS 10

public:
/**
 * Made a sum reduction over elements in v
 * v -> Vector over reduction will be done
 * n -> Number of elements of v
 */
    static int parSum(int v[], unsigned int n){
        int mutex_variable = 0;
        int global_result = 0;
        thread* thread_pool[NUMBER_OF_THREADS];
        
        /**
         * Create threads
         */
        for(unsigned int i = 0; i < NUMBER_OF_THREADS; i++)
        {
            int actual_start = ;
            int actual_n = ; 
            thread_pool[i] = new thread(thread_sum, ref(&v[actual_start]), actual_n, ref(mutex_variable), ref(global_result));
        }

        /**
         * Wait for threads end
         */
        for(unsigned int i = 0; i < NUMBER_OF_THREADS; i++)
        {
            thread_pool[i]->join();
        }

        /**
         * Delete threads
         */
        for(unsigned int i = 0; i < NUMBER_OF_THREADS; i++)
        {
            delete thread_pool[i];
        }
    }

    /**
     * n -> number of elements to process by the thread
     */
    int thread_sum(int v[], unsigned int n, int& mutex_variable, int& global_variable){

    }
};