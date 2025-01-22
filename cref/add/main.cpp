#include <iostream>
#include "mxint8_add.h"
#include <bitset>
#include <cassert>
#include <cstddef>
#include <iostream>
#include <cmath>

MXINT8_vector mx_add(MXINT8_vector a, MXINT8_vector b, bool do_largest_result_rounding);

std::bitset<24> max_mag (std::array<std::bitset<24>, 32> vector);

std::bitset<24> scaled_sum(std::bitset<8> smaller, std::bitset<8> larger, uint8_t scale_difference);

std::bitset<8> round_to_even_MXINT8(std::bitset<24> intermediate_sum_element, int32_t ones_index);

template<size_t N, size_t M>
std::bitset<M> bitset_slice(const std::bitset<N>& b, size_t start, size_t length);

int main() {


    MXINT8_vector a, b;
    a.scale = 127;  // Set the 8-bit field (max value for 8 bits)
    b.scale = 127;
    
    // Fill the array with values
    for (int i = 0; i < 32; ++i) {
        a.elements[i] = i % 256;  // Example values, ensuring they fit in 8 bits
        b.elements[i] = i % 256;
        std::cout << "diff: " << + a.elements[i].to_ulong() << std::endl;
    }
    std::cout << "" << + a.scale.to_ulong() << std::endl;
    MXINT8_vector y = mx_add(a,b, 1);
    // Access elements
    std::cout << "" << + y.scale.to_ulong() << std::endl;
    for (int i = 0; i < 32; ++i) {
        std::cout << "" << + a.elements[i].to_ulong() << " + " << + b.elements[i].to_ulong() << " = " << + y.elements[i].to_ulong() << std::endl;
    }


    return 0;
}

// employs round to even
// with the intermediate format, the only way to do things combinationally is with a bunch of case statements for every
// different scale difference possibility less than 16 (or 13).
MXINT8_vector mx_add(MXINT8_vector a, MXINT8_vector b, bool do_largest_result_rounding) { //, bool round_largest_first) {
    // TODO: consider normalize . validate input

    // TODO: zero case (what scale)

    // determine which scale is larger
    MXINT8_vector larger = (static_cast<uint8_t>(a.scale.to_ulong()) > static_cast<uint8_t>(b.scale.to_ulong())) ? a : b;
    MXINT8_vector smaller = (static_cast<uint8_t>(a.scale.to_ulong()) > static_cast<uint8_t>(b.scale.to_ulong())) ? b : a;
    uint8_t scale_difference = static_cast<uint8_t>(larger.scale.to_ulong()) - static_cast<uint8_t>(smaller.scale.to_ulong());

    // TODO: verify return nan if nan
    if (a.scale == 0b11111111) return a; // RTL: RAISE NaN FLAG
    if (b.scale == 0b11111111) return b; // RTL: RAISE NaN FLAG

    // return larger if scale difference is so large that any addition would always result in a rounded result equivalent to larger
    if ((scale_difference) > 14) { // TODO: verify; subject to change
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
    std::bitset<24> largest_sum = max_mag(intermediate_sum);
    int32_t max_res = static_cast<int32_t>(largest_sum.to_ulong());
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
    // clamp
    if  (new_scale_n > 127) new_scale_n = 127; // RTL: RAISE OVERFLOW FLAG
    if  (new_scale_n < -127) new_scale_n = -127; // RTL: RAISE OVERFLOW FLAG
    // for proper encoding we bias with 127
    int32_t new_scale_e8 = new_scale_n + 127; 
    // 4: scale the elements accordingly, employing roundTiesToEven
    // normal numbers that exceed the max normal representation of the element
    // data type should be clamped to the max normal, preserving the sign.
    int32_t scale_change = new_scale_n - intermediate_scale_n;
    // Note: the scale change equals how much the implicit decimal point should be shifted, left if positive, right if negative
    // 24-bit intermediate: 00000000_00000000_00.000000
    int32_t ones_index = 6 + scale_change; 
    // Account for case where rounding of the max result would change the scale
    // TODO: VERIFY
    if (do_largest_result_rounding) {
        std::bitset<8> slice = bitset_slice<24, 8>(largest_sum, ones_index - 6, 8);
        bool round_up = 0;
        for (int j = 0; j < ones_index - 7; j++) {
            round_up |= largest_sum[j];
        }
        // if rounding to even would cause largest result to round up with scale change,
        // and the scale is not already maxed, we increment the magnitude of the scale
        if ((slice == 0b11111111 || slice == 0b01111111) && round_up && (abs(new_scale_n) < 127)) {
            new_scale_n += 1;
            new_scale_e8 += 1;
            ones_index += 1;
        }
    }
    
    // 4b: round to even, Clamp if out of range, convert to 8 bit format // refer to sum case statements 
    MXINT8_vector y;
    y.scale = new_scale_e8;
    for (int i = 0; i < 32; i++) {
        if (ones_index < 0) { // no rounding needed if scale decreased, just have trailing zeros
            for (int j = ones_index + 1; j >= 0; j--) {
                y.elements[i][j] = intermediate_sum[i][j];
            }
        } else { // when scale increased / stay the same
            // perform round to even where necessary
            y.elements[i] = round_to_even_MXINT8(intermediate_sum[i], ones_index);
        }
    }
    return y;
}
    
// returns max magnitude value found in intermediate format vector
std::bitset<24> max_mag (std::array<std::bitset<24>, 32> vector) {
    uint32_t curr_max = 0;
    uint32_t index = 0;
    for (int i = 0; i < 32; i++) {
        uint32_t curr;
        // if negative (2's comp), negate (flip & + 1)
        if (vector[i][23]) curr = static_cast<uint32_t>(vector[i].flip().to_ulong()) + 1; 
        else curr = static_cast<uint32_t>(vector[i].to_ulong());
        if (curr > curr_max) {
            curr_max = curr;
            index = i;
        }
    }
    return vector[index];
}

// returns intermediate format sum
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

// performs round to even on one intermediate format element from the vector, returning a MXINT8 result
std::bitset<8> round_to_even_MXINT8(std::bitset<24> intermediate_sum_element, int32_t ones_index) {

    std::bitset<8> slice = bitset_slice<24, 8>(intermediate_sum_element, ones_index - 6, 8);

    if (intermediate_sum_element[ones_index - 7]) { // if tie or greater
        bool round_up = 0;
        for (int i = 0; i < ones_index - 7; i++) {
            round_up |= intermediate_sum_element[i];
        }
        if (round_up || intermediate_sum_element[ones_index - 6]) { // if round_up or there is tie with odd mx-LSB, round up
            if (slice == 0b11111111 || slice == 0b01111111) { // don't round if element capped at max mag already for this scale
                return slice;
            } else {
                unsigned long rounded_val = slice.to_ulong() + 1;
                return std::bitset<8>(rounded_val);
            }
        } else { // tie with even mx-LSB, round down (truncate) 
            return slice;
        }
    } 
    // general round down (truncate) case
    return slice;
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