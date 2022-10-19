// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.cairo.common.uint256 import Uint256

// Internal dependencies
from kakarot.model import model
from utils.utils import Helpers
from kakarot.execution_context import ExecutionContext
from kakarot.stack import Stack
from kakarot.constants import Constants

// @title BlockInformation information opcodes.
// @notice This file contains the functions to execute for block information opcodes.
// @author @abdelhamidbakhta
// @custom:namespace BlockInformation
namespace BlockInformation {
    // Define constants.
    const GAS_COST_CHAINID = 2;

    // @notice CHAINID operation.
    // @dev Get the chain ID.
    // @custom:since Instanbul
    // @custom:group Block Information
    // @custom:gas 3
    // @custom:stack_consumed_elements 0
    // @custom:stack_produced_elements 1
    // @return The pointer to the updated execution context.
    func exec_chainid{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        ctx: model.ExecutionContext*
    ) -> model.ExecutionContext* {
        %{ print("0x46 - CHAINID") %}
        // Get the chain ID.
        let chain_id = Helpers.to_uint256(Constants.CHAIN_ID);
        let stack: model.Stack* = Stack.push(ctx.stack, chain_id);

        // Update the execution context.
        // Update context stack.
        let ctx = ExecutionContext.update_stack(ctx, stack);
        // Increment gas used.
        let ctx = ExecutionContext.increment_gas_used(ctx, GAS_COST_CHAINID);
        return ctx;
    }
}