// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { BaseAdapter } from "sense-v1-core/adapters/BaseAdapter.sol";
import { ERC4626 } from "@rari-capital/solmate/src/mixins/ERC4626.sol";

interface PriceOracleLike {
    /// @notice Get the price of an underlying asset.
    /// @param underlying The underlying asset to get the price of.
    /// @return The underlying asset price in ETH as a mantissa (scaled by 1e18).
    /// Zero means the price is unavailable.
    function price(address underlying) external view returns (uint256);
}

/// @notice Adapter contract for cTokens
contract ERC4626Adapter is BaseAdapter {
    using SafeTransferLib for ERC20;

    uint256 public immutable BASE_UINT;

    constructor(
        address _divider,
        address _target,
        address _oracle,
        uint64 _ifee,
        address _stake,
        uint256 _stakeSize,
        uint256 _minm,
        uint256 _maxm,
        uint16 _mode,
        uint64 _tilt
    )
        BaseAdapter(
            _divider,
            _target,
            address(ERC4626(_target).asset()),
            _oracle,
            _ifee,
            _stake,
            _stakeSize,
            _minm,
            _maxm,
            _mode,
            _tilt,
            31
        )
    {
        BASE_UINT = 10**ERC4626(target).decimals();
        ERC20(underlying).approve(target, type(uint256).max);
        ERC20(target).approve(target, type(uint256).max);
    }

    function scale() external override returns (uint256) {
        return ERC4626(target).convertToAssets(BASE_UINT);
    }

    function scaleStored() external view override returns (uint256) {
        return ERC4626(target).convertToAssets(BASE_UINT);
    }

    function getUnderlyingPrice() external view override returns (uint256) {
        return PriceOracleLike(oracle).price(underlying);
    }

    function wrapUnderlying(uint256 assets) external override returns (uint256 _shares) {
        ERC20(underlying).safeTransferFrom(msg.sender, address(this), assets);
        _shares = ERC4626(target).deposit(assets, msg.sender);
    }

    function unwrapTarget(uint256 shares) external override returns (uint256 _assets) {
        ERC20(target).safeTransferFrom(msg.sender, address(this), shares);
        _assets = ERC4626(target).redeem(shares, msg.sender, address(this));
    }
}