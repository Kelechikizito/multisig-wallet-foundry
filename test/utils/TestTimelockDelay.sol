// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {MultiSigTimelock} from "src/MultiSigTimelock.sol";

contract TestTimelockDelay is MultiSigTimelock {
    function getTimelockDelay(uint256 value) external pure returns (uint256) {
        return _getTimelockDelay(value);
    }
}
