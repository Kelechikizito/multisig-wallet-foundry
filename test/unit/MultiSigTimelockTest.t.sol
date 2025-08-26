// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {MultiSigTimelock} from "src/MultiSigTimelock.sol";

contract MultiSigTimeLockTest is Test {
    MultiSigTimelock multiSigTimelock;

    address public SIGNER_ONE = makeAddr("signer_one");
    address public SIGNER_TWO = makeAddr("signer_two");
    address public SIGNER_THREE = makeAddr("signer_three");
    address public SIGNER_FOUR = makeAddr("signer_four");
    address public SIGNER_FIVE = makeAddr("signer_five");

    function setUp() public {
        multiSigTimelock = new MultiSigTimelock();
        // multiSigTimelock.trans
    }

    //////////////////////////////
    /// SIGNING ROLE TESTS   /////
    //////////////////////////////
    function testGrantSigningRoles() public {
        // ARRANGE
        uint256 signerCount = 5;
        address[] memory signersArray = new address[](5);

        // ACT
        multiSigTimelock.grantSigningRole(SIGNER_ONE);
        signersArray[0] = SIGNER_ONE;
        multiSigTimelock.grantSigningRole(SIGNER_TWO);
        signersArray[1] = SIGNER_TWO;
        multiSigTimelock.grantSigningRole(SIGNER_THREE);
        signersArray[2] = SIGNER_THREE;
        multiSigTimelock.grantSigningRole(SIGNER_FOUR);
        signersArray[3] = SIGNER_FOUR;
        multiSigTimelock.grantSigningRole(SIGNER_FIVE);
        signersArray[4] = SIGNER_FIVE;

        // ASSERT
        assertEq(multiSigTimelock.getSignerCount(), signerCount);
        assertEq(abi.encodePacked(multiSigTimelock.getSigners()), abi.encodePacked(signersArray));
    }

    function testGrantSigningRoleRevertsIfMoreThanFiveAddress() public {
        // ARRANGE
        address notAllowedAddress = makeAddr("notAllowedAddress");

        // ACT
        multiSigTimelock.grantSigningRole(SIGNER_ONE);
        multiSigTimelock.grantSigningRole(SIGNER_TWO);
        multiSigTimelock.grantSigningRole(SIGNER_THREE);
        multiSigTimelock.grantSigningRole(SIGNER_FOUR);
        multiSigTimelock.grantSigningRole(SIGNER_FIVE);

        // ASSERT
        vm.expectRevert(MultiSigTimelock.MultiSigTimelock__MaximumSignersReached.selector);
        multiSigTimelock.grantSigningRole(notAllowedAddress);
    }

    function testGrantSigningRoleRevertsIfAlreadyASigner() public {
        // ACT
        multiSigTimelock.grantSigningRole(SIGNER_ONE);
        multiSigTimelock.grantSigningRole(SIGNER_TWO);
        multiSigTimelock.grantSigningRole(SIGNER_THREE);
        multiSigTimelock.grantSigningRole(SIGNER_FOUR);

        // ASSERT
        vm.expectRevert(MultiSigTimelock.MultiSigTimelock__AccountIsAlreadyASigner.selector);
        multiSigTimelock.grantSigningRole(SIGNER_FOUR);
    }

    //////////////////////////////
    /// GETTER FUNCTIONS TEST /////
    //////////////////////////////
    function testGetTimeDelay() public view {
        // ARRANGE
        uint256 sevenDaysTimeDelay = 7 days;
        uint256 twoDaysTimeDelay = 2 days;
        uint256 oneDayTimeDelay = 1 days;

        // ACT & ASSERT
        assertEq(multiSigTimelock.getSevenDaysTimeDelay(), sevenDaysTimeDelay);
        assertEq(multiSigTimelock.getTwoDaysTimeDelay(), twoDaysTimeDelay);
        assertEq(multiSigTimelock.getOneDayTimeDelay(), oneDayTimeDelay);
    }
}
