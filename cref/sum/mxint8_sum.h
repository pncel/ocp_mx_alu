#ifndef MXINT8_ADD_H
#define MXINT8_ADD_H

#include <cstdint>
#include <string>
#include <iostream>
#include <bit>
#include <version>
#include <array> 

#include <bitset>
#include <cassert>
#include <cstddef>

#define BLOCK_SIZE 32
#define FP32_INF_MANTISSA 0
#define FP32_INF_EXPONENT 255
#define FP32_NaN_EXPONENT 255


using u32 = uint32_t;
using u16 = uint16_t;
using s32 = int32_t;
using s8 = int8_t;

using namespace std;


struct MXINT8_vector {
    bitset<8> scale;  // 8-bit field
    uint8_t bias : 8;
    // std::bitset<8> bias;
    array<bitset<8>, 32> elements;  // Array of 32 8-bit elements

    MXINT8_vector() : scale(0), bias(127), elements{} {}  // Initialize scale to 0 and elements to all zeros
};


struct FP32_ieee754 {
    bitset<1> sign; 
    bitset<8> exponent;  // 8-bit field
    bitset<23> mantissa;  // 23-bit field
    uint8_t bias : 8;
    bool overflow_flag;
    bool unused_flag;
    FP32_ieee754() : sign(0), exponent(0), mantissa(0), bias(127), overflow_flag(false), unused_flag(false)  {}
    
};

// template<
//     typename Repr,
//     Repr scale_mask,
//     Repr element_mask,
//     Repr exponent_bit,
//     Repr exponent_bias
// >
// using binary32 = MXINT8Impl<
//     u16,
//     0b1111'1111'0000'0000,   
//     0b0000'0000'1111'1111,
//     8,
//     127
// >;

FP32_ieee754 sum_reference(MXINT8_vector a);

#endif // FLOAT_BY_HAND_H