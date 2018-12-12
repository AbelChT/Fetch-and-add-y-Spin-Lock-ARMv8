//
// Created by Abel Chils Trabanco
// On 12/12/18
//

#include <iostream>
#include "Reduce2D.h"

#define TEST_SIZE 1000000

using namespace std;

int main() {
    cout << "Pre-reduction config start ..." << endl;

    /* initialize random seed: */
    srand(time(NULL));

    int v[TEST_SIZE];

    for (int i = 0; i < TEST_SIZE; ++i) {
        v[i] = rand() % 3;
    }

    cout << "Reduction start ..." << endl;

    clock_t begin = clock();
    Reduce2D::parSum(v, TEST_SIZE);
    clock_t end = clock();
    double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;

    cout << "Time taken: " << elapsed_secs << endl;
    return 0;
}