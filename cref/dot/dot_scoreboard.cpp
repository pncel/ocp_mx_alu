#include "mxint8_dot.h"
#include <iostream>
#include <vector>
#include <bitset>
#include <cmath>
#include <string>
#include <fstream>
#include <sstream>
using namespace std;

// g++ -o scoreboard dot_scoreboard.cpp dot_mxint8_reference.cpp
// ./scoreboard > test_result.txt
// bool compare_result(){

// }

void processFile_and_answer(const string& fileName) {
    MXINT8_vector a, b;
    ifstream inputFile(fileName);
    if (!inputFile) {
        cerr << "Error: Could not open file " << fileName << endl;
        return;
    }

    string line;
    int case_cnt = -1, element_cnt = 0;
    FP32_ieee754 expected_result;
    FP32_ieee754 actual_result;
    while (getline(inputFile, line)) {
        
        // Check if the line starts with "Case"
        if (line.find("Case") != string::npos) {
            // cout << line << endl;
            case_cnt++;
            continue;
        }

        // Check if the line starts with "element"
        if (line.find("element[") != string::npos) {
            int elementIndex;
            int decimalValueA;
            int decimalValueB;
            element_cnt ++;
            // Parse the element index, bitset, and decimal value
            sscanf(line.c_str(), "element[%d] = %d, %d", &elementIndex, &decimalValueA, &decimalValueB);
            a.elements[elementIndex] = decimalValueA; // two vector input
            b.elements[elementIndex] = decimalValueB;
            continue;
            
        }

        // Check if the line starts with "scale"
        if (line.find("scale") != string::npos) {
            int scaleValue;
            // Parse the scale value
            sscanf(line.c_str(), "scale = %d", &scaleValue);
            a.scale = scaleValue;
            b.scale = scaleValue;
            continue;
          

        }

        // Check if the line starts with "expected result"
        if (line.find("expected") != string::npos) {
            char binary_str[33];
            
            // Parse the scale value
            sscanf(line.c_str(), "expected result = %s", binary_str);
            string binary_string(binary_str);
            expected_result.sign = bitset<1>(binary_string.substr(0, 1));
            expected_result.exponent = bitset<8>(binary_string.substr(1, 8));
            expected_result.mantissa = bitset<23>(binary_string.substr(9, 23));
            //sum the scalar
            actual_result = dot_mxint8_reference(a, b);

        }
        // unused
        if (line.find("unused") != string::npos){
            int unused;
            if (sscanf(line.c_str(), "unused flag = %d", &unused) == 1)
                expected_result.unused_flag = static_cast<bool>(unused);
            else {
                cout << "Warning: Failed to parse  " << line << endl;
            }
        }
        // overflow
        if (line.find("overflow") != string::npos){
            int overflow;
            sscanf(line.c_str(), "overflow flag = %d", &overflow);
            expected_result.overflow_flag = static_cast<bool>(overflow);

            // compare result
            cout << "case" << case_cnt << " ";

            if (expected_result.sign != actual_result.sign) {
                cout << "Mismatch in sign: "
                    << "Expected = " << expected_result.sign << ", Actual = " << actual_result.sign << endl;
            }

            if (expected_result.exponent != actual_result.exponent) {
                cout << "Mismatch in exponent: "
                    << "Expected = " << expected_result.exponent << ", Actual = " << actual_result.exponent << endl;
            }

            if (expected_result.mantissa != actual_result.mantissa) {
                cout << "Mismatch in mantissa: "
                    << "Expected = " << expected_result.mantissa << ", Actual = " << actual_result.mantissa << endl;
            }

            if (expected_result.overflow_flag != actual_result.overflow_flag) {
                cout << "Mismatch in overflow_flag: "
                    << "Expected = " << expected_result.overflow_flag << ", Actual = " << actual_result.overflow_flag
                    << "\nanswer =" <<actual_result.exponent <<actual_result.mantissa << endl;
            }

            if (expected_result.unused_flag != actual_result.unused_flag) {
                cout << "Mismatch in unused_flag: "
                    << "Expected = " << expected_result.unused_flag << ", Actual = " << actual_result.unused_flag << endl;
            }

            if(expected_result.overflow_flag == actual_result.overflow_flag && expected_result.unused_flag == actual_result.unused_flag && 
                expected_result.sign == actual_result.sign && expected_result.exponent == actual_result.exponent && 
                expected_result.mantissa == actual_result.mantissa){
                cout << "pass" << endl;
            }
            continue;
        }


        
        
    }

    

    inputFile.close();
}


int main(){
   
    string fileName = "dot_testcases.txt"; 
    processFile_and_answer(fileName);


}