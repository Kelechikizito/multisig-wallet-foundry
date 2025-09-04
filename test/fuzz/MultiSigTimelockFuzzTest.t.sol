// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {MultiSigTimelock} from "src/MultiSigTimelock.sol";
import {EthRejector} from "test/utils/EthRejector.sol";
import {TestTimelockDelay} from "test/utils/TestTimelockDelay.sol";


/**
 * @title
 * @author
 * @dev Stateless Fuzzing
 */
contract MultiSigTimeLockFuzzTest is Test {
    MultiSigTimelock multiSigTimelock;
    EthRejector ethRejector;
    TestTimelockDelay testTimelockDelay;

    address public OWNER = address(this);
    address public SIGNER_TWO = makeAddr("signer_two");
    address public SIGNER_THREE = makeAddr("signer_three");
    address public SIGNER_FOUR = makeAddr("signer_four");
    address public SIGNER_FIVE = makeAddr("signer_five");


    function setUp() public {
        multiSigTimelock = new MultiSigTimelock();
    }

    modifier grantSigningRoles() {
        multiSigTimelock.grantSigningRole(SIGNER_TWO);
        multiSigTimelock.grantSigningRole(SIGNER_THREE);
        multiSigTimelock.grantSigningRole(SIGNER_FOUR);
        multiSigTimelock.grantSigningRole(SIGNER_FIVE);
        _;
    }

    function testFuzz_GetTimelockDelay(uint256 value) public {
        testTimelockDelay = new TestTimelockDelay();
        uint256 delay = testTimelockDelay.getTimelockDelay(value); 

        if (value < 1 ether) {
            assertEq(delay, 0);
        } else if (value < 10 ether) {
            assertEq(delay, 1 days);
        } else if (value < 100 ether) {
            assertEq(delay, 2 days);
        } else {
            assertEq(delay, 7 days);
        }

        // Invariant: Delay is always one of the defined constants
        assertTrue(delay == 0 || delay == 1 days || delay == 2 days || delay == 7 days);
    }

    // function testFuzz_GrantSigningRole(address[] calldata randomAddresses) public grantSigningRoles {
    //     // Constrain to realistic inputs: up to 5 addresses, but since we start with some signers, limit fuzz
    //     vm.assume(randomAddresses.length <= 5 - multiSigTimelock.getSignerCount()); // Avoid exceeding max signers

    //     for (uint256 i = 0; i < randomAddresses.length; i++) {
    //         address newSigner = randomAddresses[i];
    //         // Assume valid non-zero, non-existing signer
    //         vm.assume(newSigner != address(0) && !multiSigTimelock.hasRole(multiSigTimelock.getSigningRole(), newSigner));

    //         multiSigTimelock.grantSigningRole(newSigner);
    //         assertTrue(multiSigTimelock.hasRole(multiSigTimelock.getSigningRole(), newSigner));
    //         assertEq(multiSigTimelock.getSignerCount(), multiSigTimelock.getSignerCount() + 1); // Invariant: count increases
    //     }

    //     // Invariant: Never exceed max signers
    //     assertLe(multiSigTimelock.getSignerCount(), multiSigTimelock.getMaximumSignerCount());
    // }

}