// comment: 
// g++ -o scoreboard scoreboard.cpp sum_reference.cpp
// ./scoreboard > test_result.txt
#include "mxint8_sum.h"
#include <iostream>
#include <bitset>
#include <cmath>
using namespace std;


FP32_ieee754 to_FP32(int MXINT8_sum_result, int shared_scale){

    FP32_ieee754 FP32_sum_result;

    FP32_sum_result.overflow_flag = false;
    FP32_sum_result.unused_flag = false;
    FP32_sum_result.sign = (MXINT8_sum_result >= 0) ? 0 : 1;

    MXINT8_sum_result = abs(MXINT8_sum_result);

    // cout << "\n" <<"MXINT8_sum_result = " << MXINT8_sum_result << endl;
    //*************************normal case*************************

    //check how many bits MXINT8_sum_result has and shift accordingly
    int MXINT8_sum_bitcnt = log(MXINT8_sum_result)/log(2) + 1;
    // cout <<"MXINT8_sum_bitcnt = "<<MXINT8_sum_bitcnt << endl;
    
    if(shared_scale - 6 + MXINT8_sum_bitcnt -1 > 0){
        //do not overflow
        if(shared_scale - 6 + MXINT8_sum_bitcnt -1 < 255){
            //mantissa
            FP32_sum_result.mantissa = MXINT8_sum_result * pow(2 , 24 - MXINT8_sum_bitcnt);
            
            //exponent
            FP32_sum_result.exponent = shared_scale - 6 + MXINT8_sum_bitcnt -1;
        }
        //overflow -> clamp
        else {
            FP32_sum_result.mantissa = FP32_INF_MANTISSA;
            FP32_sum_result.exponent = FP32_INF_EXPONENT;
            // overflow
            FP32_sum_result.overflow_flag = true;
        }
    }
    //*************************subnormal case*************************
    else{
        FP32_sum_result.mantissa = MXINT8_sum_result * pow(2 , 24 - MXINT8_sum_bitcnt - 1);
        FP32_sum_result.exponent = 0;
    }

    return FP32_sum_result;
}

FP32_ieee754 sum_reference( MXINT8_vector a ) {
    // MXINT8_vector a;
    FP32_ieee754 FP32_sum_result;
    // a.scale = 1;
    // cout << "shared_scale= " <<a.scale.to_ulong()<<endl;
    // for(int i = 0; i < BLOCK_SIZE; i ++){
    //     // a.elements[i] = 255%(i+1) * pow(-1,i) ;
    //     a.elements[i] = 255%(i+1);
    //     // a.elements[i] = 1;
    //     // cout << a.elements[i].to_ulong() << "+" ;
    // }
    // cout << endl;
    //Mantissa of FP32 is not signed so take abs value
    int MXINT8_sum_result = 0;
    int dec_element = 0;

    for(int i = 0; i < BLOCK_SIZE; i ++){
        dec_element = a.elements[i][7] ?  a.elements[i].to_ulong() - 256 : a.elements[i].to_ulong();
        // check unused
        FP32_sum_result.unused_flag = (dec_element == -128);
        MXINT8_sum_result = MXINT8_sum_result + dec_element;
    }

    FP32_sum_result = to_FP32(MXINT8_sum_result, (int)a.scale.to_ulong());
  
    return FP32_sum_result;

}
