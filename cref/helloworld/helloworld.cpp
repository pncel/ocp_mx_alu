#include <iostream>
#include <vector>
#include <string>

#include <bitset>
#include <cassert>
#include <cstddef>
#include <iostream>

using namespace std;

int main()
{
    vector<string> msg {"Hello", "C++", "World", "from", "VS Code", "and the C++ extension!"};
    // constructors:
    std::bitset<8> b1;
    std::bitset<8> b2{0xA}; // == 0B1010
    for (const string& word : msg)
    {
        cout << word << " ";
    }
    cout << endl;

    return 0;
}

void printDecimal(){}

#include <iostream>
#include <bitset>

using namespace std;

// int main() {
//     bitset<8> a("10101010");
//     bitset<8> b("01010101");

//     bitset<8> sum;
//     bool carry = 0;

//     for (int i = 0; i < 8; i++) {
//         bool bitA = a[i];
//         bool bitB = b[i];

//         sum[i] = (bitA ^ bitB) ^ carry;
//         carry = (bitA & bitB) | (bitA & carry) | (bitB & carry);
//     }

//     cout << "a: " << a << endl;
//     cout << "b: " << b << endl;
//     cout << "sum: " << sum << endl;
//     cout << "carry: " << carry << endl;

//     return 0;
// }