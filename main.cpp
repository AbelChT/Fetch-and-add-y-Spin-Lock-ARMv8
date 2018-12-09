#include <iostream>

using namespace std;
extern "C" int myadd(int x, int y);
extern "C" void spin_lock();
extern "C" void spin_unlock();

int main() {
    int c = myadd(1,5);
    cout << c << endl;
    return 0;
}