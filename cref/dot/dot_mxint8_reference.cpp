#include <iostream>
#include "mxint8_dot.h"
#include "parameter.h"
#include <bitset>
#include <cassert>
#include <cstddef>
#include <iostream>
#include <cmath>

using namespace std;
template<size_t N, size_t M>
std::bitset<M> bitset_slice(const std::bitset<N>& b, size_t start, size_t length);


FP32_ieee754 dot_mxint8_reference(MXINT8_vector a, MXINT8_vector b) {
    // TODO zero case: determine what to do
    // TODO NaN case: determine what to do

    // Multiply the block scales (X) through adding the scale factors bits after applying bias; 
    // Add because scale bits encode X through 2^(scale_int - 127); need 9 bits
    FP32_ieee754 result = FP32_ieee754();
    // NaN case
    if (a.scale == 0b11111111 || b.scale == 0b11111111) {
        result.NaN_flag = 1;
        result.exponent = 0b11111111;
        result.mantissa = 1; //ambiguous
        return result;
    }
    int32_t new_scale = ((static_cast<int32_t>(a.scale.to_ulong())-127) + (static_cast<int32_t>(b.scale.to_ulong())-127)) + 127;
    // std::cout << "new scale " << new_scale << std::endl;

    // scale overflow and underflow managed in helper function
    
    // Multiply all the elements, need 16 bits; 
    // sum all the element products, need 21 bits (scalar block 32 = 2^5, 5+16)
    int32_t sum_of_products = 0;
    bool unused_flag = false;
    for (int i = 0; i < 32; i++) {
        int32_t operand_a = a.elements[i][7] ? a.elements[i].to_ulong() - 256 : a.elements[i].to_ulong();  //verify sign works
        int32_t operand_b = b.elements[i][7] ? b.elements[i].to_ulong() - 256 : b.elements[i].to_ulong(); 
        // check unused
        unused_flag = unused_flag || (operand_a == -128) || (operand_b == -128);  //OLIVER NOTE: should be OR'd with itself so it stays set when set once
        sum_of_products += operand_a * operand_b;
    }
    // cout << "\n" <<"Intermediate Dot Product Result (extended mxint8 element) " << std::bitset<32> {abs(sum_of_products)} << endl;
    // cout << "\n" <<"Absolute Value " << std::bitset<32> {abs(sum_of_products)} << endl;
    // fit into FP32 (IEEE754) representation, clamp if too large
    result = to_FP32(sum_of_products, new_scale);
    result.unused_flag = unused_flag;
    return result;
    //return
}

// perplexity bitset from slice of larger bitset
template<size_t N, size_t M>
std::bitset<M> bitset_slice(const std::bitset<N>& b, size_t start, size_t length) {
    assert(start + length <= N);
    std::bitset<M> result;
    for (size_t i = 0; i < length; ++i) {
        result[i] = b[start + i];
    }
    return result;
}

// modified from Leo's sum reference model
FP32_ieee754 to_FP32(int32_t MXINT8_sum_result, int32_t shared_scale){

    FP32_ieee754 FP32_sum_result;
    FP32_sum_result.overflow_flag = false;
    FP32_sum_result.underflow_flag = false;
    FP32_sum_result.unused_flag = false;

    // zero
    if (MXINT8_sum_result == 0) {
        // might be equivalent to just set MXINT8_sum_bitcnt to 23 
        FP32_sum_result.sign = 0;
        FP32_sum_result.exponent = 0;
        FP32_sum_result.mantissa = 0;
        return FP32_sum_result;
    }
    FP32_sum_result.sign = (MXINT8_sum_result >= 0) ? 0 : 1;
    MXINT8_sum_result = abs(MXINT8_sum_result); // magnitude only

    //*************************normal case*************************

    //check how many bits MXINT8_sum_result has and shift accordingly
    // RTL: Find leading 1
    int MXINT8_sum_bitcnt = log(MXINT8_sum_result)/log(2) + 1; // checks out 2/10/25
    // cout << "lead hot bit index = " << MXINT8_sum_bitcnt-1 << endl;
    //do not overflow
    // - 6 + MXINT8_sum_bitcnt -1 evaluates to the distance the implicit decimal needs to move to be adjacent to the leading 1

    if (shared_scale - 6 + MXINT8_sum_bitcnt -1 > 0) { 

        if(shared_scale - 6 + MXINT8_sum_bitcnt -1 < 255){
            //mantissa; shift so that leading 1 "falls off the cliff" (implicit leading 1 not encoded)
            // here we sometimes shift left so we still need all 32 bits until done shifting 
            std::bitset<32> m23 = MXINT8_sum_result; //TODO discuss with Leo why this is necessary
            m23 = m23 << (32 - MXINT8_sum_bitcnt + 1); // Imagine this as just removing leading zeros & implicit 1.
            FP32_sum_result.mantissa = bitset_slice<32, 23>(m23, 9, 23);
            // FP32_sum_result.mantissa = MXINT8_sum_result * pow(2 , 24 - MXINT8_sum_bitcnt); //VERIFY implicit leading 1.. checks out 2/11/25
            // FP32_sum_result.mantissa = MXINT8_sum_result << (24 - MXINT8_sum_bitcnt); //OLIVER VERIFY EQUIVALENT?
            //exponent
            // Imagine this as just compensating for moving the implicit decimal to be adjacent to the leading 1
            FP32_sum_result.exponent = shared_scale - 6 + MXINT8_sum_bitcnt -1; // VERIFY WORKS BOTH DIR. 3/10: verify - 6 explicit incorporation
        }
        //overflow -> clamp
        else {
            FP32_sum_result.overflow_flag = true;
            FP32_sum_result.mantissa = FP32_MAX_MANTISSA; // RTL throw OVERFLOW
            FP32_sum_result.exponent = FP32_MAX_EXPONENT;
        }
    }
    //*************************underflow and subnormal case*************************
    else  {
        // in both underflow and subnormal, retain sign
        // in underflow result should be 0
        // here we sometimes shift left so we still need all 32 bits until done shifting 
        std::bitset<32> m23 = MXINT8_sum_result; //check
        int32_t undershoot =  shared_scale - 6 + MXINT8_sum_bitcnt - 1;
        int32_t correction = 32 - MXINT8_sum_bitcnt + undershoot;
        // correction = 32 - MXINT8_sum_bitcnt + shared_scale - 6 + MXINT8_sum_bitcnt - 1
        // correction = 32 + shared_scale - 6 - 1
        // Imagine this as just removing or adding leading zeros to fit into the subnormal case range
        if (correction < 0) m23 = m23 >> abs(correction);
        if (correction > 0) m23 = m23 << correction;
        FP32_sum_result.mantissa = bitset_slice<32, 23>(m23, 9, 23); //parse out first 23 bits
        if (FP32_sum_result.mantissa == 0) FP32_sum_result.underflow_flag = true; // RAISE underflow flag
        FP32_sum_result.exponent = 0; //ALWAYS ZERO

    } 
    // //*************************subnormal case*************************
    // else {
    //     // subnormal
    //     std::bitset<23> m23 = MXINT8_sum_result;
    //     FP32_sum_result.mantissa = m23 << (24 - MXINT8_sum_bitcnt - 1); // Imagine this as just removing leading zeros.
    //     // FP32_sum_result.mantissa = MXINT8_sum_result * pow(2 , 24 - MXINT8_sum_bitcnt - 1);
    //     FP32_sum_result.exponent = shared_scale - 6 + MXINT8_sum_bitcnt -1; //ALWAYS ZERO
    // }

    return FP32_sum_result;
}