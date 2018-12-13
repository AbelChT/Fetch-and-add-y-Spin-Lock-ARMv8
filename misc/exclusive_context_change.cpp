//
// Created by Abel Chils Trabanco
// On 12/12/18
//

#include <iostream>
#include <unistd.h>

using namespace std;

extern "C" void read_exclusive(int* address);

extern "C" int store_exclusive(int* address);

int main()
{
    int exclusive_variable = 0;
    int result1;
    int result2;

    // This calls will be ok because no context change happens
    read_exclusive(&exclusive_variable);
    result1 = store_exclusive(&exclusive_variable);

    // This one will fail because the context change, read README for more info
    read_exclusive(&exclusive_variable);
    sleep(2);
    result2 = store_exclusive(&exclusive_variable);


    if(( result1 == 0 ) && ( result2 != 0 )) {
        cout << "Predicted behaviour" << endl;
    }else{
        cout << "Non predicted behaviour" << endl;
    }

    return 0;
}
