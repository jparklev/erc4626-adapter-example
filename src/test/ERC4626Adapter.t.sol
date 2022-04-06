// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import { Vm } from "forge-std/Vm.sol";
import { stdCheats } from "forge-std/stdlib.sol";
import { DSTest } from "ds-test/test.sol";

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { MockERC4626 } from "solmate/test/utils/mocks/MockERC4626.sol";
import { MockERC20 } from "solmate/test/utils/mocks/MockERC20.sol";
import { DSTestPlus } from "solmate/test/utils/DSTestPlus.sol";

import { ERC4626Adapter } from "../ERC4626Adapter.sol";
import { Divider, TokenHandler } from "sense-v1-core/Divider.sol";

contract ERC4626AdapterTest is DSTestPlus {
    MockERC20 public stake;
    MockERC20 public underlying;
    MockERC4626 public target;

    ERC4626Adapter public erc4626Adapter;
    Divider public divider;

    uint64 public constant ISSUANCE_FEE = 0.01e18;
    uint256 public constant STAKE_SIZE = 1e18;
    uint256 public constant MIN_MATURITY = 2 weeks;
    uint256 public constant MAX_MATURITY = 14 weeks;
    uint16 public constant MODE = 0;

    function setUp() public {
        TokenHandler tokenHandler = new TokenHandler();
        divider = new Divider(address(this), address(tokenHandler));
        divider.setPeriphery(address(this));
        tokenHandler.init(address(divider));

        stake = new MockERC20("Mock Stake", "MS", 18);
        underlying = new MockERC20("Mock Underlying", "MU", 18);
        target = new MockERC4626(ERC20(address(underlying)), "Mock ERC-4626", "M4626");

        underlying.mint(address(this), 1e18);

        erc4626Adapter = new ERC4626Adapter(
            address(divider),
            address(target),
            address(0),
            ISSUANCE_FEE,
            address(stake),
            STAKE_SIZE,
            MIN_MATURITY,
            MAX_MATURITY,
            MODE,
            0
        );
    }

    function test4626WrapUnwrap(uint256 wrapAmt) public {
        wrapAmt = bound(wrapAmt, 1, 1e18);

        // Approvals
        target.approve(address(erc4626Adapter), type(uint256).max);
        underlying.approve(address(erc4626Adapter), type(uint256).max);

        // Full cycle
        uint256 prebal = underlying.balanceOf(address(this));
        uint256 wrappedAmt = erc4626Adapter.wrapUnderlying(wrapAmt);
        assertEq(wrappedAmt, target.balanceOf(address(this)));
        erc4626Adapter.unwrapTarget(wrappedAmt);
        uint256 postbal = underlying.balanceOf(address(this));

        assertEq(prebal, postbal);

        // Deposit underlying tokens into the vault
        underlying.approve(address(target), 0.5e18);
        // Initialize
        target.deposit(0.25e18, address(this));
        assertEq(target.totalSupply(), 0.25e18);
        assertEq(target.totalAssets(), 0.25e18);
        // Init a non-one expchange rate
        target.deposit(0.25e18, address(this));
        assertEq(target.totalSupply(), 0.5e18);
        assertEq(target.totalAssets(), 0.5e18);
        uint256 targetAmtPostDeposit = target.balanceOf(address(this));

        wrapAmt = bound(wrapAmt, 1, 0.5e18);

        // Run the cycle again now that the vault has some underlying tokens
        prebal = underlying.balanceOf(address(this));
        wrappedAmt = erc4626Adapter.wrapUnderlying(wrapAmt);
        assertEq(wrappedAmt + targetAmtPostDeposit, target.balanceOf(address(this)));
        erc4626Adapter.unwrapTarget(wrappedAmt);
        postbal = underlying.balanceOf(address(this));

        assertEq(prebal, postbal);
    }

    function test4626Scale() public {
        // Deposit initial underlying tokens into the vault
        underlying.approve(address(target), 0.5e18);
        target.deposit(0.5e18, address(this));

        // Initializes at 1:1
        assertEq(erc4626Adapter.scale(), 1e18);

        // Vault mutates by +2e18 tokens (simulated yield returned from strategy)
        target.totalAssets();
        underlying.mint(address(target), 2e18);
        target.totalAssets();

        // The value per share is now 5x higher
        assertEq(erc4626Adapter.scale(), 5e18);
    }
}