#include "mxint8_add.h"
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
    MXINT8_vector expected_result;
    MXINT8_vector actual_result;
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
        if (line.find("scale_A") != string::npos) {
            int scaleValueA;
            // Parse the scale value
            sscanf(line.c_str(), "scale_A = %d", &scaleValueA);
            a.scale = scaleValueA;
            continue;
        }

        // Check if the line starts with "scale"
        if (line.find("scale_B") != string::npos) {
            int scaleValueB;
            // Parse the scale value
            sscanf(line.c_str(), "scale_B = %d", &scaleValueB);
            b.scale = scaleValueB;
            actual_result = add_mxint8_reference(a, b, 1);
            continue;
        }

        // Check if the line starts with "expected result"
        if (line.find("expected_") != string::npos) {
            // char binary_str[33];
            int elementIndex;
            int decimalValueY;
            // Parse the scale value
            sscanf(line.c_str(), "expected_result[%d] = %d", &elementIndex, &decimalValueY);
            expected_result.elements[elementIndex] = decimalValueY;
            
            continue;
        }

        // Check if the line starts with "scale"
        if (line.find("scale_Y") != string::npos) {
            int scaleValueY;
            // Parse the scale value
            sscanf(line.c_str(), "scale_Y = %d", &scaleValueY);
            expected_result.scale = scaleValueY;
            
            // compare result
            cout << "\ncase" << case_cnt << " ";
            if(expected_result.elements == actual_result.elements && 
                expected_result.scale == actual_result.scale) {
                    cout << "PASS: " << endl; //<< actual_result.sign << "_" << actual_result.exponent << "_" << actual_result.mantissa << "; ";
                    // cout << "flags underflow_overflow_unused_NaN: " << actual_result.underflow_flag << actual_result.overflow_flag << actual_result.unused_flag << actual_result.NaN_flag << endl;
            } else {
                cout << "FAIL: " << endl;// << actual_result.sign << "_" << actual_result.exponent << "_" << actual_result.mantissa << "; ";
                //cout << "flags underflow_overflow_unused_NaN: " << actual_result.underflow_flag << actual_result.overflow_flag << actual_result.unused_flag << actual_result.NaN_flag << endl;
                if (expected_result.elements != actual_result.elements) {
                    for (int i = 0; i < 32; i++) {
                        if (expected_result.elements[i] != actual_result.elements[i]) {
                            int value_E = expected_result.elements[i].to_ulong(); // Convert to unsigned long
                            int value_A = actual_result.elements[i].to_ulong(); // Convert to unsigned long
                            if (expected_result.elements[i][7]) { // Check if MSB (sign bit) is set
                                value_E -= 256; // Adjust for 2's complement (subtract 2^8)
                            }
                            if (actual_result.elements[i][7]) { // Check if MSB (sign bit) is set
                                value_A -= 256; // Adjust for 2's complement (subtract 2^8)
                            }
                            cout << "   Mismatch @ index "<< i << ": Expected = " << value_E << ", Actual = " << value_A << endl;
                        }
                    }

                }
    
                if (expected_result.scale != actual_result.scale) {
                    cout << "   Mismatch in scale: "
                        << "Expected = " << expected_result.scale << ", Actual = " << actual_result.scale << endl;
                }
    
            } 
            continue;
        }
    }
    inputFile.close();
}


int main(){
   
    string fileName = "add_testcases_key.txt"; 
    processFile_and_answer(fileName);


}