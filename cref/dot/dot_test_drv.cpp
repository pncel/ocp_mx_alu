// comment: 
// g++ -o test dot_test_drv.cpp
// ./test > dot_testcases.txt
// This file generate testcase for dot_reference.cpp
#include "mxint8_dot.h"
#include <iostream>
#include <vector>
#include <bitset>
#include <cmath>
#include <string>
using namespace std;

MXINT8_vector Normal_Cases() {
    MXINT8_vector testcase;
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 255 - 127); //[-127, 127]
    }
    testcase.scale = rand() % 255; //[0, 254] avoids NaN
    return testcase;
}

MXINT8_vector all_large_positive_elements() {
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 27 + 100); //[100, 126]
    }
    testcase.scale = rand() % 255; //[0, 254] avoids NaN
    return testcase;
}

MXINT8_vector all_large_negative_elements() {
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 27 - 127 ); //[-127, -101]
    }
    testcase.scale = rand() % 255; //[0, 254] avoids NaN
    return testcase;
}

MXINT8_vector large_scale_elements() {
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 255 - 127 ); //[-127 ~ 127]
    }
    testcase.scale = rand() % 16 + 239; //[0, 254] avoids NaN
    return testcase;
}

MXINT8_vector small_scale__elements() {
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 155 - 127 ); //[-127 ~ 27]
    }
    testcase.scale = rand() % 16 ;
    return testcase;
}

MXINT8_vector subnormal_edge() { //1*2**-126
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 9 - 9 ); //[-127 ~ 27]
    }
    testcase.scale = rand() % 8 ;
    return testcase;
}

MXINT8_vector positive_overflow() { 
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 7 + 120 ); 
    }
    testcase.scale = rand() % 4 + 250 ;
    return testcase;
}
MXINT8_vector negative_overflow() { 
    MXINT8_vector testcase;
    
    for (int i = 0; i < 32; i++) {
        testcase.elements[i] = bitset<8>(rand() % 7 - 127 );
    }
    testcase.scale = rand() % 4 + 250 ;
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

void publish_testcase_2vec(MXINT8_vector testcase_A, MXINT8_vector testcase_B) {
    for (int i = 0; i < 32; i++) {
        int value_A = testcase_A.elements[i].to_ulong(); // Convert to unsigned long
        int value_B = testcase_B.elements[i].to_ulong(); // Convert to unsigned long
        if (testcase_A.elements[i][7]) { // Check if MSB (sign bit) is set
            value_A -= 256; // Adjust for 2's complement (subtract 2^8)
        }
        if (testcase_B.elements[i][7]) { // Check if MSB (sign bit) is set
            value_B -= 256; // Adjust for 2's complement (subtract 2^8)
        }
        cout << "element[" << i << "] = " << value_A << ", " << value_B << endl;
    }
    
    cout << "scale_A = " << testcase_A.scale.to_ulong() << endl;
    cout << "scale_B = " << testcase_B.scale.to_ulong() << endl;
    cout << "expected result = " << "11111111111111111111111111111" << endl;
    cout << "unused flag = " << "11111111111111111111111111111" << endl;
    cout << "underflow flag = " << "11111111111111111111111111111" << endl;
    cout << "overflow flag = " << "11111111111111111111111111111" << endl;
}

int main(){
    int seed = 777;
    cout << "Random Seed: "<< seed << endl;
    srand(seed); //time(NULL) for always random
    MXINT8_vector vector_A, vector_B;
    FP32_ieee754 FP32_sum_result;
    int case_cnt = 0;

    // Normal A dot Normal B
    cout << "\nNormal A dot B: "<< endl;
    for(int i = 0; i<10; i++){
        cout << "\nCase = " << case_cnt << endl;
        vector_A = Normal_Cases();
        vector_B = Normal_Cases();
        publish_testcase_2vec(vector_A, vector_B);
        case_cnt ++;
    }

    // large positive elements
    cout << "\nA dot B all_large_positive_elements"<<endl;
    for(int i = 0; i<3; i++){
        cout << "\nCase = " << case_cnt << endl;
        vector_A = all_large_positive_elements();
        vector_B = all_large_positive_elements();
        publish_testcase_2vec(vector_A, vector_B);
        
        case_cnt ++;

    }
    
    cout << "\nall_large_negative_elements"<<endl;
    for(int i = 0; i<3; i++){
        cout << "\nCase = " << case_cnt << endl;
        vector_A = all_large_negative_elements();
        vector_B = all_large_negative_elements();
        publish_testcase_2vec(vector_A, vector_B);
        
        case_cnt ++;
    }


    cout << "\nlarge_scale_elements" <<endl;
    for(int i = 0; i<3; i++){
        cout << "\nCase = " << case_cnt << endl;
        vector_A = large_scale_elements();
        vector_B = large_scale_elements();
        publish_testcase_2vec(vector_A, vector_B);
        
        case_cnt ++;
    }


    cout << "\nsmall_scale__elements" <<endl;
    for(int i = 0; i<3; i++){
        cout << "\nCase = " << case_cnt << endl;
        vector_A = small_scale__elements();
        vector_B = small_scale__elements();
        publish_testcase_2vec(vector_A, vector_B);
        case_cnt ++;
    }


    cout << "\nsubnormal_edge" <<endl;
    for(int i = 0; i<5; i++){
        cout << "\nCase = " << case_cnt << endl;
        vector_A = subnormal_edge();
        vector_B = subnormal_edge();
        publish_testcase_2vec(vector_A, vector_B);
        case_cnt ++;
    }


    cout << "\npositive_overflow" <<endl;
    for(int i = 0; i<3; i++){
        cout << "\nCase = " << case_cnt << endl;
        vector_A = positive_overflow();
        vector_B = positive_overflow();
        publish_testcase_2vec(vector_A, vector_B);
        case_cnt ++;
    }


    cout << "\nnegative_overflow" <<endl;
    for(int i = 0; i<3; i++){
        cout << "\nCase = " << case_cnt << endl;
        vector_A = negative_overflow();
        vector_B = negative_overflow();
        publish_testcase_2vec(vector_A, vector_B);
        case_cnt ++;
    }
}