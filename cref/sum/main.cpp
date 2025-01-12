#include "parameter.h"
#include "mxint8_sum.h"
#include <iostream>
#include <bitset>
#include <cmath>
using namespace std;

int MXINT8_sum(MXINT8_vector a){
    int a_sum_result = 0;
    int dec_element = 0;

    for(int i = 0; i < BLOCK_SIZE; i ++){
        dec_element = a.elements[i][7] ?  a.elements[i].to_ulong() - 256 : a.elements[i].to_ulong();
        cout << dec_element << " ";
        a_sum_result = a_sum_result + dec_element;
    }
    return a_sum_result;
    
}

FP32_ieee754 to_FP32(int MXINT8_sum_result, int shared_scale){

    FP32_ieee754 FP32_sum_result;

    FP32_sum_result.sign = (MXINT8_sum_result >= 0) ? 0 : 1;
    MXINT8_sum_result = abs(MXINT8_sum_result);

    cout << "\n" <<"MXINT8_sum_result = " << MXINT8_sum_result << endl;
    //*************************normal case*************************

    //check how many bits MXINT8_sum_result has and shift accordingly
    int MXINT8_sum_bitcnt = log(MXINT8_sum_result)/log(2) + 1;
    cout << MXINT8_sum_bitcnt << endl;
    //do not overflow
    if(shared_scale - 6 + MXINT8_sum_bitcnt -1 > 0){

        if(shared_scale - 6 + MXINT8_sum_bitcnt -1 < 255){
            //mantissa
            FP32_sum_result.mantissa = MXINT8_sum_result * pow(2 , 24 - MXINT8_sum_bitcnt);
            
            //exponent
            FP32_sum_result.exponent = shared_scale - 6 + MXINT8_sum_bitcnt -1;
        }
        //overflow -> clamp
        else {
            FP32_sum_result.mantissa = FP32_MAX_MANTISSA;
            FP32_sum_result.exponent = FP32_MAX_EXPONENT;
        }
    }
    //*************************subnormal case*************************
    else{
        FP32_sum_result.mantissa = MXINT8_sum_result * pow(2 , 24 - MXINT8_sum_bitcnt - 1);
        FP32_sum_result.exponent = 0;
    }

    


    return FP32_sum_result;
}

int main() {
    MXINT8_vector a;
    FP32_ieee754 FP32_sum_result;
    a.scale = 1;

    for(int i = 0; i < BLOCK_SIZE; i ++){
        // a.elements[i] = 255%(i+1) * pow(-1,i) ;
        // a.elements[i] = 255%(i+1);
        a.elements[i] = 1;
        cout << a.elements[i].to_ulong() << "+" ;
    }
    cout << endl;
    //Mantissa of FP32 is not signed so take abs value
    int MXINT8_sum_result = MXINT8_sum(a);
    FP32_sum_result = to_FP32(MXINT8_sum_result, (int)a.scale.to_ulong());
    cout << "FP32_sum_result.exponent = " <<FP32_sum_result.exponent << endl;
    cout << "FP32_sum_result.mantissa = " << FP32_sum_result.mantissa << endl;
    cout << "FP32_sum_result.sign = " << FP32_sum_result.sign << endl;


}
