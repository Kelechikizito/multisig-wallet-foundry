// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title EthRejector
 * @dev A contract that rejects any incoming Ether transfers.
 */
contract EthRejector {
    receive() external payable {
        revert("Always fails");
    }
}
