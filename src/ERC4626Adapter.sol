// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { BaseAdapter } from "sense-v1-core/adapters/BaseAdapter.sol";
import { ERC4626 } from "@rari-capital/solmate/src/mixins/ERC4626.sol";

/// @notice Adapter contract for tokenized vaults implementing ERC4626
contract ERC4626Adapter is BaseAdapter {}
