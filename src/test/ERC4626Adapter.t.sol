// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import { Vm } from "forge-std/Vm.sol";
import { stdCheats } from "forge-std/stdlib.sol";
import { DSTest } from "ds-test/test.sol";

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { MockERC20 } from "solmate/test/utils/mocks/MockERC20.sol";
import { DSTestPlus } from "solmate/test/utils/DSTestPlus.sol";

contract ERC4626AdapterTest is DSTestPlus, stdCheats {
    Vm internal constant vm = Vm(HEVM_ADDRESS);

    function setUp() public {}

    function testExample() public {
        assertTrue(true);
    }
}
