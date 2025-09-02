// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MultiSigTimelock} from "src/MultiSigTimelock.sol";

/**
 * @title ProposeTransactionScript
 * @author Kelechi Kizito Ugwu
 * @notice This script proposes a transaction to the MultiSigTimelock contract.
 * It also writes the transaction ID to a file for later use.
 */
contract ProposeTransactionScript is Script {
    address constant RECEIVING_ADDRESS = 0x93923B42Ff4bDF533634Ea71bF626c90286D27A0;
    uint256 constant AMOUNT = 5e15;
    bytes constant DATA = hex"";

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MultiSigTimelock", block.chainid);
        proposeTransaction(payable(mostRecentlyDeployed));
    }

    function proposeTransaction(address payable multiSigTimelockContractAddress) public {
        vm.startBroadcast();
        uint256 txnId =
            MultiSigTimelock(multiSigTimelockContractAddress).proposeTransaction(RECEIVING_ADDRESS, AMOUNT, DATA);
        vm.stopBroadcast();

        // This step writes txnId to file
        string memory txnIdStr = vm.toString(txnId);
        vm.writeFile("./script/txnId.txt", txnIdStr);
        console2.log("Transaction proposed with ID:", txnId);
    }
}

/**
 * @title ConfirmTransactionScript
 * @author Kelechi Kizito Ugwu
 * @notice This script confirms a transaction on the MultiSigTimelock contract.
 * It reads the transaction ID from a file created during the proposal step.
 */
contract ConfirmTransactionScript is Script {
    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MultiSigTimelock", block.chainid);

        // This will read txnId from file
        string memory txnIdStr = vm.readFile("./script/txnId.txt");
        uint256 txnId = vm.parseUint(txnIdStr);

        confirmTransaction(payable(mostRecentlyDeployed), txnId);
    }

    function confirmTransaction(address payable multiSigTimelockContractAddress, uint256 txnId) public {
        vm.startBroadcast();
        MultiSigTimelock(multiSigTimelockContractAddress).confirmTransaction(txnId);
        vm.stopBroadcast();
    }
}

/**
 * @title ExecuteTransactionScript
 * @author Kelechi Kizito Ugwu
 * @notice This script executes a confirmed transaction on the MultiSigTimelock contract.
 * It reads the transaction ID from a file created during the proposal step.
 */
contract ExecuteTransactionScript is Script {
    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MultiSigTimelock", block.chainid);

        // This will read txnId from file
        string memory txnIdStr = vm.readFile("./script/txnId.txt");
        uint256 txnId = vm.parseUint(txnIdStr);

        executeTransaction(payable(mostRecentlyDeployed), txnId);
    }

    function executeTransaction(address payable multiSigTimelockContractAddress, uint256 txnId) public {
        vm.startBroadcast();
        MultiSigTimelock(multiSigTimelockContractAddress).executeTransaction(txnId);
        vm.stopBroadcast();
    }
}
