#include <iostream>
#include "mxint8_add.h"
#include <bitset>
#include <cassert>
#include <cstddef>
#include <iostream>

int main() {


    MXINT8_vector a, b;
    a.scale = 255;  // Set the 8-bit field (max value for 8 bits)
    b.scale = 0;

    // Fill the array with values
    for (int i = 0; i < 32; ++i) {
        a.elements[i] = i % 256;  // Example values, ensuring they fit in 8 bits
        b.elements[i] = i % 256;
        std::cout << "diff: " << + a.elements[i] << std::endl;
    }

    // Access elements
    uint8_t fifthElement = a.elements[4];  // Zero-based indexing

    return 0;
}

// employs round to even
// with the intermediate format, the only way to do things combinationally is with a bunch of case statements for every
// different scale difference possibility less than 16 (or 13).
MXINT8_vector mx_add(MXINT8_vector a, MXINT8_vector b) {
    //normalize . validate input

    //zero case

    // determine which scale is larger
    MXINT8_vector larger = (static_cast<uint8_t>(a.scale.to_ulong()) > static_cast<uint8_t>(b.scale.to_ulong())) ? a : b;
    MXINT8_vector smaller = (static_cast<uint8_t>(a.scale.to_ulong()) > static_cast<uint8_t>(b.scale.to_ulong())) ? b : a;
    uint8_t scale_difference = static_cast<uint8_t>(larger.scale.to_ulong()) - static_cast<uint8_t>(smaller.scale.to_ulong());

    // return larger if scale difference is so large that any addition would always result in a rounded result equivalent to larger
    if ((scale_difference) > 14) {
        return larger;
    }

    // Intermediate format, 14 + 8 = 22, + 1 bit for overflow, + another bit because we like even numbers = 24
    std::array<std::bitset<24>, 32> intermediate_sum {};
    for (int i = 0; i < 32; i++) {
        intermediate_sum[i] = scaled_sum(smaller.elements[i], larger.elements[i], scale_difference);
    }
    // now follow 6.3 Conversion from Vector of Scalar Elements to MX-compliant Format
    // Instructions view the scale X as 2^n, where n = E8 - 127. In reality we are solving for n or E8, not X, since we encode E8
    // 0: find largest magnitude element in sum
    int32_t max_res = static_cast<int32_t>(max_mag(intermediate_sum));
    int32_t intermediate_scale_n = static_cast<int32_t>(smaller.scale.to_ulong()) - 127; //n
    // 1: find largest power of 2 less than or equal to what was found in step 1
    // THIS IS ASSUMING BIAS IS APPLIED ALREADY
    int32_t max_pow2_res_n = (static_cast<int32_t>(log2(max_res)) - 6) + intermediate_scale_n; // MINUS 6

    // 2: find largest power of 2 representable in MX data type
    // MXINT8 largest power of 2 is 2^0, we use n from 2^n
    int32_t max_rep_n = 0;

    // 3: calls to divide largest pow2 <= max result by the largest pow2 representable in element data type (why??). (2^n1 / 2^n2)
    //    however we solve for the n values not 2^n values, so we SUBTRACT

    int32_t new_scale_n = (max_pow2_res_n - max_rep_n); // no change with MXINT8, subtract 0
    // for proper encoding we bias with 127
    int32_t new_scale_e8 = new_scale_n + 127; // TODO: what to do if this not in [-127, 127]? maybe keep intermediate scale

    // 4: scale the elements accordingly, employing roundTiesToEven
    // normal numbers that exceed the max normal representation of the element
    // data type should be clamped to the max normal, preserving the sign.
    int32_t scale_change = new_scale_n - intermediate_scale_n;

    /// 4a unecessary, see note above 4b
    // 4a: bit shift by the change in scale, left if negative, right if positive. 
    // for (int i = 0; i < 32; i++) {
    //     if (scale_change < 0) {
    //         intermediate_sum[i] <<= (scale_change * -1);
    //     } else {
    //         int sign = intermediate_sum[i][23];
    //         intermediate_sum[i] >>= scale_change;
    //         // this needs to be done with case statements in Verilog
    //         if (sign) {
    //             // sign extend
    //             for (int j = 24-scale_change; j < 24; j++) { // VERIFY
    //                 intermediate_sum[i].set(j);
    //             }
    //         }
    //     }
    // }
    // Note: the scale change equals how much the implicit decimal point should be shifted, left if positive, right if negative
    // 24-bit intermediate:
    // 00000000_00000000_00.000000
    int32_t ones_index = 6 + scale_change; 
    // 4b: round to even, Clamp if out of range, convert to 8 bit format
    // refer to sum case statements 
    
}

uint32_t max_mag (std::array<std::bitset<24>, 32> vector) {
    uint32_t curr_max = 0;
    for (int i = 0; i < 32; i++) {
        uint32_t curr;
        // if negative (2's comp), negate (flip & + 1)
        if (vector[i][23]) curr = static_cast<uint32_t>(vector[i].flip().to_ulong()) + 1; 
        else curr = static_cast<uint32_t>(vector[i].to_ulong());
        if (curr > curr_max) curr_max = curr;
    }
    return curr_max;
}


std::bitset<24> scaled_sum(std::bitset<8> smaller, std::bitset<8> larger, uint8_t scale_difference) {
    
    std::bitset<24> smaller_extend;
    std::bitset<24> larger_extend;
    std::bitset<24> sum;
    std::bitset<24> carry;
    
    smaller_extend |= smaller.to_ulong();
    // sign extend
    if (smaller[7]) {
        for (int i = 8; i < 24; i++) {
            smaller_extend.set(i);
        }
    }

    larger_extend |= larger.to_ulong();
    // this needs to be done with case statements on scale_difference in Verilog
    // if purely combinational (can't have dynamic for-loop or bitshift based on input)
    larger_extend <<= scale_difference; // capped at 14
    if (larger[7]) {
        for (int i = 8 + scale_difference; i < 24; i++) {
            larger_extend.set(i);
        }
    }

    // need to make carry a bitset/array of 24 as well for combinational
    
    // bit 0
    sum[0] = (smaller_extend[0] ^ larger_extend[0]) ^ 0;
    carry[0] = (smaller_extend[0] & larger_extend[0]) | (smaller_extend[0] & 0) | (larger_extend[0] & 0);
    // bits 1-23
    for (int i = 1; i < 24; i++) {
        bool bitA = smaller_extend[i];
        bool bitB = larger_extend[i];

        sum[i] = (bitA ^ bitB) ^ carry[i-1];
        carry[i] = (bitA & bitB) | (bitA & carry[i-1]) | (bitB & carry[i-1]);
    }
    

    return sum;
}
