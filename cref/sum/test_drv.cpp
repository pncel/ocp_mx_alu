// comment: 
// g++ -o test test_drv.cpp
// ./test > testcase.txt
// This file generate testcase for sum_reference.cpp
#include "mxint8_sum.h"
#include <iostream>
#include <vector>
#include <bitset>
#include <cmath>
#include <string>
using namespace std;

MXINT8_vector Normal_Cases() {
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 255 - 127); 
        int value = testcase.elements[i].to_ulong(); // Convert to unsigned long
        if (testcase.elements[i][7]) { // Check if MSB (sign bit) is set
            value -= 256; // Adjust for 2's complement (subtract 2^8)
        }
        cout << "element[" << i << "] = " << value << endl;
    }
    testcase.scale = rand() % 255;
    cout << "scale = " << testcase.scale.to_ulong() << endl;
    cout << "expected result = " << endl;
    cout << "unused flag = " << endl;
    cout << "overflow_flag = " << endl;
    return testcase;
}

MXINT8_vector all_large_passative_elements() {
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 27 + 100); //100 ~ 127
        int value = testcase.elements[i].to_ulong(); // Convert to unsigned long
        if (testcase.elements[i][7]) { // Check if MSB (sign bit) is set
            value -= 256; // Adjust for 2's complement (subtract 2^8)
        }
        cout << "element[" << i << "] = " << value << endl;

    }
    testcase.scale = rand() % 255;
    cout << "scale = " << testcase.scale.to_ulong() << endl;
    cout << "expected result = " << endl;
    cout << "unused flag = " << endl;
    cout << "overflow_flag = " << endl;
    return testcase;
}

MXINT8_vector all_large_negative_elements() {
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 27 -127 ); //-100 ~ -127
        int value = testcase.elements[i].to_ulong(); // Convert to unsigned long
        if (testcase.elements[i][7]) { // Check if MSB (sign bit) is set
            value -= 256; // Adjust for 2's complement (subtract 2^8)
        }
        cout << "element[" << i << "] = " << value << endl;

    }
    testcase.scale = rand() % 255;
    cout << "scale = " << testcase.scale.to_ulong() << endl;
    cout << "expected result = " << endl;
    cout << "unused flag = " << endl;
    cout << "overflow_flag = " << endl;
    return testcase;
}

MXINT8_vector large_scale_elements() {
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 255 - 127 ); //-100 ~ -127
        int value = testcase.elements[i].to_ulong(); // Convert to unsigned long
        if (testcase.elements[i][7]) { // Check if MSB (sign bit) is set
            value -= 256; // Adjust for 2's complement (subtract 2^8)
        }
        cout << "element[" << i << "] = " << value << endl;

    }
    testcase.scale = rand() % 16 + 239;
    cout << "scale = " << testcase.scale.to_ulong() << endl;
    cout << "expected result = " << endl;
    cout << "unused flag = " << endl;
    cout << "overflow_flag = " << endl;
    return testcase;
}

MXINT8_vector small_scale__elements() {
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 155 -127 ); //-100 ~ -127
        int value = testcase.elements[i].to_ulong(); // Convert to unsigned long
        if (testcase.elements[i][7]) { // Check if MSB (sign bit) is set
            value -= 256; // Adjust for 2's complement (subtract 2^8)
        }
        cout << "element[" << i << "] = " << value << endl;

    }
    testcase.scale = rand() % 16 ;
    cout << "scale = " << testcase.scale.to_ulong() << endl;
    cout << "expected result = " << endl;
    cout << "unused flag = " << endl;
    cout << "overflow_flag = " << endl;
    return testcase;
}

MXINT8_vector subnormal_edge() { //1*2**-126
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 9 - 9 ); 
        int value = testcase.elements[i].to_ulong(); // Convert to unsigned long
        if (testcase.elements[i][7]) { // Check if MSB (sign bit) is set
            value -= 256; // Adjust for 2's complement (subtract 2^8)
        }
        cout << "element[" << i << "] = " << value << endl;
    }
    testcase.scale = rand() % 8 ;
    cout << "scale = " << testcase.scale.to_ulong() << endl;
    cout << "expected result = " << endl;
    cout << "unused flag = " << endl;
    cout << "overflow_flag = " << endl;
    return testcase;
}

MXINT8_vector positive_overflow() { 
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 7 + 120 ); 
        int value = testcase.elements[i].to_ulong(); // Convert to unsigned long
        if (testcase.elements[i][7]) { // Check if MSB (sign bit) is set
            value -= 256; // Adjust for 2's complement (subtract 2^8)
        }
        cout << "element[" << i << "] = " << value << endl;
    }
    testcase.scale = rand() % 4 + 250 ;
    cout << "scale = " <<  testcase.scale.to_ulong() << endl;
    cout << "expected result = " << endl;
    cout << "unused flag = " << endl;
    cout << "overflow_flag = " << endl;
    return testcase;
}
MXINT8_vector negative_overflow() { 
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 7 - 127 );
        int value = testcase.elements[i].to_ulong(); // Convert to unsigned long
        if (testcase.elements[i][7]) { // Check if MSB (sign bit) is set
            value -= 256; // Adjust for 2's complement (subtract 2^8)
        } 
        cout << "element[" << i << "] = " << value << endl;
    }
    testcase.scale = rand() % 4 + 250 ;
    cout << "scale = " << testcase.scale.to_ulong() << endl;
    cout << "expected result = " << endl;
    cout << "unused flag = " << endl;
    cout << "overflow_flag = " << endl;
    return testcase;
}
// MXINT8_vector Small_Cases() {
//     MXINT8_vector testcase;
    
//     for (int j = 0; j < 32; j++) {
//         testcase.elements[j] = (rand() % 255 - 127); 
//     }
//     testcase.scale = rand() % 8;

//     return testcase;
// }


int main(){
    srand(time(NULL)); 
    MXINT8_vector testcase;
    FP32_ieee754 FP32_sum_result;
    int case_cnt = 0;
    cout << "Normal: "<< endl;
    for(int i = 0; i<10; i++){
        cout << "Case = " << case_cnt << endl;
        testcase = Normal_Cases();
        case_cnt ++;
    }
    cout << "all_large_passative_elements"<<endl;
    for(int i = 0; i<3; i++){
        cout << "Case = " << case_cnt << endl;
        testcase = all_large_passative_elements();
        case_cnt ++;

    }
    cout << "all_large_negative_elements"<<endl;
    for(int i = 0; i<3; i++){
        cout << "Case = " << case_cnt << endl;
        testcase = all_large_negative_elements();
        case_cnt ++;
    }
    cout << "large_scale_elements" <<endl;
    for(int i = 0; i<3; i++){
        cout << "Case = " << case_cnt << endl;
        testcase = large_scale_elements();
        case_cnt ++;
    }
    cout << "small_scale__elements" <<endl;
    for(int i = 0; i<3; i++){
        cout << "Case = " << case_cnt << endl;
        testcase = small_scale__elements();
        case_cnt ++;
    }
    cout << "subnormal_edge" <<endl;
    for(int i = 0; i<5; i++){
        cout << "Case = " << case_cnt << endl;
        testcase = subnormal_edge();
        case_cnt ++;
    }
    cout << "positive_overflow" <<endl;
    for(int i = 0; i<3; i++){
        cout << "Case = " << case_cnt << endl;
        testcase = positive_overflow();
        case_cnt ++;
    }
    cout << "negative_overflow" <<endl;
    for(int i = 0; i<3; i++){
        cout << "Case = " << case_cnt << endl;
        testcase = negative_overflow();
        case_cnt ++;
    }
}