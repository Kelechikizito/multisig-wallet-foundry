// SPDX-License-Identfier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MultiSigTimelock} from "src/MultiSigTimelock.sol";

contract DeployMultiSigTimelock is Script {
    function run() public returns (MultiSigTimelock) {
        return deployMultiSigTimelock();
    }

    function deployMultiSigTimelock() public returns (MultiSigTimelock) {
        vm.startBroadcast();
        MultiSigTimelock multiSigTimelock = new MultiSigTimelock();
        vm.stopBroadcast();
        return multiSigTimelock;
    }
}
