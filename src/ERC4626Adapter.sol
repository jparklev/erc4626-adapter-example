// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { BaseAdapter } from "sense-v1-core/adapters/BaseAdapter.sol";
import { ERC4626 } from "@rari-capital/solmate/src/mixins/ERC4626.sol";

/// @notice Adapter contract for tokenized vaults implementing ERC4626
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
}
