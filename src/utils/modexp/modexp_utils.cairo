from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_and,
    uint256_check,
    uint256_mul_div_mod,
    uint256_mul,
    uint256_eq,
    uint256_lt,
    uint256_shr,
    uint256_sub,
    uint256_unsigned_div_rem,
)
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.registers import get_label_location

// @title ModExpHelper Functions
// @notice This file contains a selection of helper functions for modular exponentiation and gas cost calculation.
// @author @dragan2234
// @custom:namespace ModExpHelpers
namespace ModExpHelpers {
    const GAS_COST_MOD_EXP = 200;

    func calculate_modexp_gas{range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}(
        b_size: Uint256, e_size: Uint256, m_size: Uint256, b: Uint256, e: Uint256, m: Uint256
    ) -> (gas_cost: felt) {
        alloc_locals;
        let b_size_bits = get_u256_bitlength(b);
        let m_size_bits = get_u256_bitlength(m);
        let e_size_bits = get_u256_bitlength(e);

        assert 2 = b_size_bits;
        assert m_size_bits = 256;
        assert e_size_bits = 256;
        let e_size_bits_uint256 = Uint256(low=e_size_bits,high=0);
        let (is_less_than) = uint256_lt(Uint256(low=b_size_bits,high=0), Uint256(low=m_size_bits,high=0));

        if (is_less_than == 0) {
            tempvar max_length = Uint256(low=b_size_bits, high=0);
        } else {
            tempvar max_length = Uint256(low=e_size_bits,high=0);
        }

        assert max_length = Uint256(low=256,high=0);
        let (words_step_1, _) = uint256_add(max_length, Uint256(low=7, high=0));

        assert words_step_1 = Uint256(low=263,high=0);

        let (words, _) = uint256_unsigned_div_rem(words_step_1, Uint256(low=8, high=0));

        // assert words = Uint256(low=1,high=0);

        let (multiplication_complexity, carry) = uint256_mul(words, words);
        assert carry = Uint256(0, 0);

        assert multiplication_complexity = Uint256(low=1024,high=0);
        let (is_less_than_32) = uint256_lt(e_size_bits_uint256, Uint256(low=32, high=0));
        if (is_less_than_32 == 1) {
            let (is_zero) = uint256_eq(e, Uint256(low=0, high=0));
            if (is_zero == 0) {
                let u256_l = get_u256_bitlength(e);
                let inner_step = u256_l - 1;
                tempvar iteration_count = Uint256(low=inner_step, high=0);
                tempvar range_check_ptr = range_check_ptr;
                tempvar bitwise_ptr = bitwise_ptr;
            } else {
                tempvar iteration_count = Uint256(low=0, high=0);
                tempvar range_check_ptr = range_check_ptr;
                tempvar bitwise_ptr = bitwise_ptr;
            }
            tempvar iteration_count_res = iteration_count;
            tempvar range_check_ptr = range_check_ptr;
            tempvar bitwise_ptr = bitwise_ptr;
        } else {
            let sub_step: Uint256 = uint256_sub(e_size_bits_uint256, Uint256(low=32, high=0));

            assert 224 = sub_step;

            let (local result, local carry) = uint256_mul(Uint256(low=8, high=0), sub_step);
            assert carry = Uint256(low=0, high=0);
            let (bitwise_high) = bitwise_and(e.high, 2 ** 128 - 1);
            let (bitwise_low) = bitwise_and(e.low, 2 ** 128 - 1);
            let e_bit_length = get_u256_bitlength(Uint256(low=bitwise_low, high=bitwise_high));

            let e_bit_length_uint256 = Uint256(low=e_bit_length, high=0);
            let (subtracted_e_bit_length) = uint256_sub(
                e_bit_length_uint256, Uint256(low=1, high=0)
            );

            let (addition, _) = uint256_add(result, subtracted_e_bit_length);
            tempvar iteration_count_res = addition;
            tempvar range_check_ptr = range_check_ptr;
            tempvar bitwise_ptr = bitwise_ptr;
        }
        tempvar bitwise_ptr = bitwise_ptr;
        let another_var = iteration_count_res;
        let (mci, carry) = uint256_mul(multiplication_complexity, another_var);
        assert carry = Uint256(low=0, high=0);

        let (division_mci, _) = uint256_unsigned_div_rem(mci, Uint256(low=3, high=0));

        let (gas_is_greater_than) = uint256_lt(Uint256(low=200, high=0), division_mci);

        if ((gas_is_greater_than) == 0) {
            tempvar gas_cost = Uint256(low=GAS_COST_MOD_EXP, high=0);
        } else {
            tempvar gas_cost = division_mci;
        }
        assert division_mci = Uint256(low=13056, high=0);
        let res = gas_cost.low;
        return (gas_cost=res);
    }

    /// @title Modular exponentiation calculation
    /// @author dragan2234
    /// @dev Computes x ** y % p for Uint256 numbers via fast modular exponentiation algorithm.
    /// Time complexity is log_2(y).
    /// Loop is implemented via uint256_expmod_recursive_call() function.
    func uint256_expmod{range_check_ptr: felt}(x: Uint256, y: Uint256, p: Uint256) -> (
        remainder: Uint256
    ) {
        alloc_locals;
        let res = Uint256(low=1, high=0);
        let (r_x, r_y, r_res) = uint256_expmod_recursive_call(x, y, res, p);
        let (quotient, remainder) = uint256_unsigned_div_rem(r_res, p);
        return (remainder=remainder);
    }

    func uint256_expmod_recursive_call{range_check_ptr: felt}(
        x: Uint256, y: Uint256, res: Uint256, p: Uint256
    ) -> (r_x: Uint256, r_y: Uint256, r_res: Uint256) {
        alloc_locals;
        let (is_greater_than_zero) = uint256_lt(Uint256(low=0, high=0), y);
        if ((is_greater_than_zero) == 0) {
            return (r_x=x, r_y=y, r_res=res);
        }

        let (quotient, remainder) = uint256_unsigned_div_rem(y, Uint256(low=2, high=0));
        let (is_equal_to_one) = uint256_eq(remainder, Uint256(low=1, high=0));
        if ((is_equal_to_one) == 0) {
            let (x_res_quotient, x_res_quotient_high, x_res_remainder) = uint256_mul_div_mod(
                x, x, p
            );
            return uint256_expmod_recursive_call(x=x_res_remainder, y=quotient, res=res, p=p);
        } else {
            let (
                x_res_res_quotient, x_res_res_quotient_high, x_res_res_remainder
            ) = uint256_mul_div_mod(res, x, p);
            let (x_res_quotient, x_res_quotient_high, x_res_remainder) = uint256_mul_div_mod(
                x, x, p
            );
            return uint256_expmod_recursive_call(
                x=x_res_remainder, y=quotient, res=x_res_res_remainder, p=p
            );
        }
    }

    // / @author feltroidprime
    func get_felt_bitlength{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(x: felt) -> felt {
        alloc_locals;
        local bit_length;

        if (x == 3) {
            return 2;
        }

        if (x == 0) {
            return 0;
        }

        %{
            x = ids.x
            ids.bit_length = x.bit_length()
        %}
        // Next two lines Not necessary : will fail if pow2(bit_length) is too big, unknown cell.
        // let le = is_le(bit_length, 252);
        // assert le = 1;
        assert bitwise_ptr[0].x = x;
        let n = pow2(bit_length);
        assert bitwise_ptr[0].y = n - 1;
        tempvar word = bitwise_ptr[0].x_and_y;
        assert word = x;
        assert bitwise_ptr[1].x = x;
        let n = pow2(bit_length - 1);
        assert bitwise_ptr[1].y = n - 1;
        tempvar word = bitwise_ptr[1].x_and_y;
        assert word = x - n;
        let bitwise_ptr = bitwise_ptr + 2 * BitwiseBuiltin.SIZE;
        return bit_length;
    }

    // / @author feltroidprime
    func pow2(i) -> felt {
        let (data_address) = get_label_location(data);
        return [data_address + i];

        data:
        dw 0x1;
        dw 0x2;
        dw 0x4;
        dw 0x8;
        dw 0x10;
        dw 0x20;
        dw 0x40;
        dw 0x80;
        dw 0x100;
        dw 0x200;
        dw 0x400;
        dw 0x800;
        dw 0x1000;
        dw 0x2000;
        dw 0x4000;
        dw 0x8000;
        dw 0x10000;
        dw 0x20000;
        dw 0x40000;
        dw 0x80000;
        dw 0x100000;
        dw 0x200000;
        dw 0x400000;
        dw 0x800000;
        dw 0x1000000;
        dw 0x2000000;
        dw 0x4000000;
        dw 0x8000000;
        dw 0x10000000;
        dw 0x20000000;
        dw 0x40000000;
        dw 0x80000000;
        dw 0x100000000;
        dw 0x200000000;
        dw 0x400000000;
        dw 0x800000000;
        dw 0x1000000000;
        dw 0x2000000000;
        dw 0x4000000000;
        dw 0x8000000000;
        dw 0x10000000000;
        dw 0x20000000000;
        dw 0x40000000000;
        dw 0x80000000000;
        dw 0x100000000000;
        dw 0x200000000000;
        dw 0x400000000000;
        dw 0x800000000000;
        dw 0x1000000000000;
        dw 0x2000000000000;
        dw 0x4000000000000;
        dw 0x8000000000000;
        dw 0x10000000000000;
        dw 0x20000000000000;
        dw 0x40000000000000;
        dw 0x80000000000000;
        dw 0x100000000000000;
        dw 0x200000000000000;
        dw 0x400000000000000;
        dw 0x800000000000000;
        dw 0x1000000000000000;
        dw 0x2000000000000000;
        dw 0x4000000000000000;
        dw 0x8000000000000000;
        dw 0x10000000000000000;
        dw 0x20000000000000000;
        dw 0x40000000000000000;
        dw 0x80000000000000000;
        dw 0x100000000000000000;
        dw 0x200000000000000000;
        dw 0x400000000000000000;
        dw 0x800000000000000000;
        dw 0x1000000000000000000;
        dw 0x2000000000000000000;
        dw 0x4000000000000000000;
        dw 0x8000000000000000000;
        dw 0x10000000000000000000;
        dw 0x20000000000000000000;
        dw 0x40000000000000000000;
        dw 0x80000000000000000000;
        dw 0x100000000000000000000;
        dw 0x200000000000000000000;
        dw 0x400000000000000000000;
        dw 0x800000000000000000000;
        dw 0x1000000000000000000000;
        dw 0x2000000000000000000000;
        dw 0x4000000000000000000000;
        dw 0x8000000000000000000000;
        dw 0x10000000000000000000000;
        dw 0x20000000000000000000000;
        dw 0x40000000000000000000000;
        dw 0x80000000000000000000000;
        dw 0x100000000000000000000000;
        dw 0x200000000000000000000000;
        dw 0x400000000000000000000000;
        dw 0x800000000000000000000000;
        dw 0x1000000000000000000000000;
        dw 0x2000000000000000000000000;
        dw 0x4000000000000000000000000;
        dw 0x8000000000000000000000000;
        dw 0x10000000000000000000000000;
        dw 0x20000000000000000000000000;
        dw 0x40000000000000000000000000;
        dw 0x80000000000000000000000000;
        dw 0x100000000000000000000000000;
        dw 0x200000000000000000000000000;
        dw 0x400000000000000000000000000;
        dw 0x800000000000000000000000000;
        dw 0x1000000000000000000000000000;
        dw 0x2000000000000000000000000000;
        dw 0x4000000000000000000000000000;
        dw 0x8000000000000000000000000000;
        dw 0x10000000000000000000000000000;
        dw 0x20000000000000000000000000000;
        dw 0x40000000000000000000000000000;
        dw 0x80000000000000000000000000000;
        dw 0x100000000000000000000000000000;
        dw 0x200000000000000000000000000000;
        dw 0x400000000000000000000000000000;
        dw 0x800000000000000000000000000000;
        dw 0x1000000000000000000000000000000;
        dw 0x2000000000000000000000000000000;
        dw 0x4000000000000000000000000000000;
        dw 0x8000000000000000000000000000000;
        dw 0x10000000000000000000000000000000;
        dw 0x20000000000000000000000000000000;
        dw 0x40000000000000000000000000000000;
        dw 0x80000000000000000000000000000000;
        dw 0x100000000000000000000000000000000;
        dw 0x200000000000000000000000000000000;
        dw 0x400000000000000000000000000000000;
        dw 0x800000000000000000000000000000000;
        dw 0x1000000000000000000000000000000000;
        dw 0x2000000000000000000000000000000000;
        dw 0x4000000000000000000000000000000000;
        dw 0x8000000000000000000000000000000000;
        dw 0x10000000000000000000000000000000000;
        dw 0x20000000000000000000000000000000000;
        dw 0x40000000000000000000000000000000000;
        dw 0x80000000000000000000000000000000000;
        dw 0x100000000000000000000000000000000000;
        dw 0x200000000000000000000000000000000000;
        dw 0x400000000000000000000000000000000000;
        dw 0x800000000000000000000000000000000000;
        dw 0x1000000000000000000000000000000000000;
        dw 0x2000000000000000000000000000000000000;
        dw 0x4000000000000000000000000000000000000;
        dw 0x8000000000000000000000000000000000000;
        dw 0x10000000000000000000000000000000000000;
        dw 0x20000000000000000000000000000000000000;
        dw 0x40000000000000000000000000000000000000;
        dw 0x80000000000000000000000000000000000000;
        dw 0x100000000000000000000000000000000000000;
        dw 0x200000000000000000000000000000000000000;
        dw 0x400000000000000000000000000000000000000;
        dw 0x800000000000000000000000000000000000000;
        dw 0x1000000000000000000000000000000000000000;
        dw 0x2000000000000000000000000000000000000000;
        dw 0x4000000000000000000000000000000000000000;
        dw 0x8000000000000000000000000000000000000000;
        dw 0x10000000000000000000000000000000000000000;
        dw 0x20000000000000000000000000000000000000000;
        dw 0x40000000000000000000000000000000000000000;
        dw 0x80000000000000000000000000000000000000000;
        dw 0x100000000000000000000000000000000000000000;
        dw 0x200000000000000000000000000000000000000000;
        dw 0x400000000000000000000000000000000000000000;
        dw 0x800000000000000000000000000000000000000000;
        dw 0x1000000000000000000000000000000000000000000;
        dw 0x2000000000000000000000000000000000000000000;
        dw 0x4000000000000000000000000000000000000000000;
        dw 0x8000000000000000000000000000000000000000000;
        dw 0x10000000000000000000000000000000000000000000;
        dw 0x20000000000000000000000000000000000000000000;
        dw 0x40000000000000000000000000000000000000000000;
        dw 0x80000000000000000000000000000000000000000000;
        dw 0x100000000000000000000000000000000000000000000;
        dw 0x200000000000000000000000000000000000000000000;
        dw 0x400000000000000000000000000000000000000000000;
        dw 0x800000000000000000000000000000000000000000000;
        dw 0x1000000000000000000000000000000000000000000000;
        dw 0x2000000000000000000000000000000000000000000000;
        dw 0x4000000000000000000000000000000000000000000000;
        dw 0x8000000000000000000000000000000000000000000000;
        dw 0x10000000000000000000000000000000000000000000000;
        dw 0x20000000000000000000000000000000000000000000000;
        dw 0x40000000000000000000000000000000000000000000000;
        dw 0x80000000000000000000000000000000000000000000000;
        dw 0x100000000000000000000000000000000000000000000000;
        dw 0x200000000000000000000000000000000000000000000000;
        dw 0x400000000000000000000000000000000000000000000000;
        dw 0x800000000000000000000000000000000000000000000000;
        dw 0x1000000000000000000000000000000000000000000000000;
        dw 0x2000000000000000000000000000000000000000000000000;
        dw 0x4000000000000000000000000000000000000000000000000;
        dw 0x8000000000000000000000000000000000000000000000000;
        dw 0x10000000000000000000000000000000000000000000000000;
        dw 0x20000000000000000000000000000000000000000000000000;
        dw 0x40000000000000000000000000000000000000000000000000;
        dw 0x80000000000000000000000000000000000000000000000000;
        dw 0x100000000000000000000000000000000000000000000000000;
        dw 0x200000000000000000000000000000000000000000000000000;
        dw 0x400000000000000000000000000000000000000000000000000;
        dw 0x800000000000000000000000000000000000000000000000000;
        dw 0x1000000000000000000000000000000000000000000000000000;
        dw 0x2000000000000000000000000000000000000000000000000000;
        dw 0x4000000000000000000000000000000000000000000000000000;
        dw 0x8000000000000000000000000000000000000000000000000000;
        dw 0x10000000000000000000000000000000000000000000000000000;
        dw 0x20000000000000000000000000000000000000000000000000000;
        dw 0x40000000000000000000000000000000000000000000000000000;
        dw 0x80000000000000000000000000000000000000000000000000000;
        dw 0x100000000000000000000000000000000000000000000000000000;
        dw 0x200000000000000000000000000000000000000000000000000000;
        dw 0x400000000000000000000000000000000000000000000000000000;
        dw 0x800000000000000000000000000000000000000000000000000000;
        dw 0x1000000000000000000000000000000000000000000000000000000;
        dw 0x2000000000000000000000000000000000000000000000000000000;
        dw 0x4000000000000000000000000000000000000000000000000000000;
        dw 0x8000000000000000000000000000000000000000000000000000000;
        dw 0x10000000000000000000000000000000000000000000000000000000;
        dw 0x20000000000000000000000000000000000000000000000000000000;
        dw 0x40000000000000000000000000000000000000000000000000000000;
        dw 0x80000000000000000000000000000000000000000000000000000000;
        dw 0x100000000000000000000000000000000000000000000000000000000;
        dw 0x200000000000000000000000000000000000000000000000000000000;
        dw 0x400000000000000000000000000000000000000000000000000000000;
        dw 0x800000000000000000000000000000000000000000000000000000000;
        dw 0x1000000000000000000000000000000000000000000000000000000000;
        dw 0x2000000000000000000000000000000000000000000000000000000000;
        dw 0x4000000000000000000000000000000000000000000000000000000000;
        dw 0x8000000000000000000000000000000000000000000000000000000000;
        dw 0x10000000000000000000000000000000000000000000000000000000000;
        dw 0x20000000000000000000000000000000000000000000000000000000000;
        dw 0x40000000000000000000000000000000000000000000000000000000000;
        dw 0x80000000000000000000000000000000000000000000000000000000000;
        dw 0x100000000000000000000000000000000000000000000000000000000000;
        dw 0x200000000000000000000000000000000000000000000000000000000000;
        dw 0x400000000000000000000000000000000000000000000000000000000000;
        dw 0x800000000000000000000000000000000000000000000000000000000000;
        dw 0x1000000000000000000000000000000000000000000000000000000000000;
        dw 0x2000000000000000000000000000000000000000000000000000000000000;
        dw 0x4000000000000000000000000000000000000000000000000000000000000;
        dw 0x8000000000000000000000000000000000000000000000000000000000000;
        dw 0x10000000000000000000000000000000000000000000000000000000000000;
        dw 0x20000000000000000000000000000000000000000000000000000000000000;
        dw 0x40000000000000000000000000000000000000000000000000000000000000;
        dw 0x80000000000000000000000000000000000000000000000000000000000000;
        dw 0x100000000000000000000000000000000000000000000000000000000000000;
        dw 0x200000000000000000000000000000000000000000000000000000000000000;
        dw 0x400000000000000000000000000000000000000000000000000000000000000;
    }

    // @credits feltroidprime
    func get_u256_bitlength{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(x: Uint256) -> felt {
        alloc_locals;
        let b2 = get_felt_bitlength(x.high);
        if (b2 != 0) {
            return 128 + b2;
        } else {
            let b1 = get_felt_bitlength(x.low);
            return b1 + b2;
        }
    }
}
