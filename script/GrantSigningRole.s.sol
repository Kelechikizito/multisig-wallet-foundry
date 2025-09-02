// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MultiSigTimelock} from "src/MultiSigTimelock.sol";

/**
 * @title GrantSigningRole
 * @author Kelechi Kizito Ugwu
 * @notice This script grants signing roles to multiple signers in the MultiSigTimelock contract.
 */
contract GrantSigningRole is Script {
    address constant SIGNER_TWO = 0x93923B42Ff4bDF533634Ea71bF626c90286D27A0;
    address constant SIGNER_THREE = 0x5d4aD28bD191107E582E56E47d7407bD5F111D8b;
    address constant SIGNER_FOUR = 0x86F44aA771f0ad42a037efF70C859bb1B86c188A;
    address constant SIGNER_FIVE = 0x5375bB27ABEC8d0f69d035c58306936aA9991182;

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MultiSigTimelock", block.chainid);
        grantSigningRole(payable(mostRecentlyDeployed));
    }

    function grantSigningRole(address payable multiSigTimelockContractAddress) public {
        vm.startBroadcast();
        MultiSigTimelock(multiSigTimelockContractAddress).grantSigningRole(SIGNER_TWO);
        MultiSigTimelock(multiSigTimelockContractAddress).grantSigningRole(SIGNER_THREE);
        MultiSigTimelock(multiSigTimelockContractAddress).grantSigningRole(SIGNER_FOUR);
        MultiSigTimelock(multiSigTimelockContractAddress).grantSigningRole(SIGNER_FIVE);
        vm.stopBroadcast();
    }
}
