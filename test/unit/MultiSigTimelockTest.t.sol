// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {MultiSigTimelock} from "src/MultiSigTimelock.sol";
import {EthRejector} from "test/utils/EthRejector.sol";
import {TestTimelockDelay} from "test/utils/TestTimelockDelay.sol";

contract MultiSigTimeLockTest is Test {
    MultiSigTimelock multiSigTimelock;
    EthRejector ethRejector;
    TestTimelockDelay testTimelockDelay;

    address public OWNER = address(this);
    address public SIGNER_TWO = makeAddr("signer_two");
    address public SIGNER_THREE = makeAddr("signer_three");
    address public SIGNER_FOUR = makeAddr("signer_four");
    address public SIGNER_FIVE = makeAddr("signer_five");

    address public SPENDER_ONE = makeAddr("spender_one");
    address public SPENDER_TWO = makeAddr("spender_two");

    uint256 public OWNER_BALANCE_ONE = 0.5 ether;
    uint256 public OWNER_BALANCE_TWO = 5 ether;
    uint256 public OWNER_BALANCE_THREE = 50 ether;
    uint256 public OWNER_BALANCE_FOUR = 500 ether;

    function setUp() public {
        multiSigTimelock = new MultiSigTimelock();
        // multiSigTimelock.trans
    }

    //////////////////////////////
    /// SIGNING ROLE TESTS   /////
    //////////////////////////////
    function testOwnerIsAutoSigner() public view {
        // ASSERT
        // After deployment, owner(address(this))- in the case, should be first signer
        assertEq(multiSigTimelock.getSignerCount(), 1);
        assertTrue(multiSigTimelock.hasRole(multiSigTimelock.getSigningRole(), address(this)));
    }

    function testGrantSigningRoles() public {
        // ARRANGE
        uint256 signerCount = 5;
        address[] memory signersArray = new address[](5);

        // ACT
        signersArray[0] = OWNER;
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
        multiSigTimelock.grantSigningRole(SIGNER_TWO);
        multiSigTimelock.grantSigningRole(SIGNER_THREE);
        multiSigTimelock.grantSigningRole(SIGNER_FOUR);

        // ASSERT
        vm.expectRevert(MultiSigTimelock.MultiSigTimelock__AccountIsAlreadyASigner.selector);
        multiSigTimelock.grantSigningRole(SIGNER_FOUR);
    }

    function testGrantSigningRoleRevertsIfZeroAddresses() public {
        vm.expectRevert(MultiSigTimelock.MultiSigTimelock__InvalidAddress.selector);
        multiSigTimelock.grantSigningRole(address(0));
    }

    modifier grantSigningRoles() {
        multiSigTimelock.grantSigningRole(SIGNER_TWO);
        multiSigTimelock.grantSigningRole(SIGNER_THREE);
        multiSigTimelock.grantSigningRole(SIGNER_FOUR);
        multiSigTimelock.grantSigningRole(SIGNER_FIVE);
        _;
    }

    /////////////////////////////////////
    /// REVOKE SIGNING ROLE TESTS   /////
    /////////////////////////////////////
    function testRevokeSigningRole() public grantSigningRoles {
        multiSigTimelock.revokeSigningRole(SIGNER_TWO);
        multiSigTimelock.revokeSigningRole(SIGNER_THREE);
        multiSigTimelock.revokeSigningRole(SIGNER_FOUR);
        multiSigTimelock.revokeSigningRole(SIGNER_FIVE);
    }

    function testRevokeSigningRoleRevertsIfNotASigner() public grantSigningRoles {
        multiSigTimelock.revokeSigningRole(SIGNER_TWO);
        multiSigTimelock.revokeSigningRole(SIGNER_THREE);
        multiSigTimelock.revokeSigningRole(SIGNER_FOUR);

        vm.expectRevert(MultiSigTimelock.MultiSigTimelock__AccountIsNotASigner.selector);
        multiSigTimelock.revokeSigningRole(SIGNER_FOUR);
    }

    function testRevokeSigningRoleRevertsIfZeroAddresses() public grantSigningRoles {
        vm.expectRevert(MultiSigTimelock.MultiSigTimelock__InvalidAddress.selector);
        multiSigTimelock.revokeSigningRole(address(0));
    }

    function testRevokeSigningRoleRevertsIfOnlyOneSigner() public {
        vm.expectRevert(MultiSigTimelock.MultiSigTimelock__CannotRevokeLastSigner.selector);
        multiSigTimelock.revokeSigningRole(address(this));
    }

    /////////////////////////////////////
    /// PROPOSE TRANSACTION TESTS   /////
    /////////////////////////////////////
    function testOwnerCanProposeTransaction() public {
        // ARRANGE
        vm.deal(OWNER, OWNER_BALANCE_ONE);

        // ACT & ASSERT
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");
        console2.log("This is the first transaction ID", txnId);
        assertEq(txnId, 0);

        vm.prank(OWNER);
        uint256 txnIdTwo = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");
        console2.log("This is the second transaction ID", txnIdTwo);
        assertEq(txnIdTwo, 1);
    }

    function testProposeTransactionRevertsIfZeroAddress() public {
        // ARRANGE
        vm.deal(OWNER, OWNER_BALANCE_ONE);

        // ACT & ASSERT
        vm.prank(OWNER);
        vm.expectRevert(MultiSigTimelock.MultiSigTimelock__InvalidAddress.selector);
        multiSigTimelock.proposeTransaction(address(0), OWNER_BALANCE_ONE, hex"");
    }

    function testProposeTransactionRevertsIfNonOwner() public {
        // ARRANGE
        address nonOwner = makeAddr("non_owner");

        // ACT & ASSERT
        vm.prank(nonOwner);
        vm.expectRevert();
        multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");
    }

    modifier proposeTransactionSuccessfuly() {
        vm.deal(OWNER, OWNER_BALANCE_ONE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");
        _;
    }

    /////////////////////////////////////
    /// CONFIRM TRANSACTION TESTS   /////
    /////////////////////////////////////
    function testSignerCanConfirmTransaction() public grantSigningRoles {
        // ARRANGE
        vm.deal(OWNER, OWNER_BALANCE_ONE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_TWO);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_THREE);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_FOUR);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_FIVE);
        multiSigTimelock.confirmTransaction(txnId);
    }

    function testConfirmTransactionRevertsIfAlreadySigned() public grantSigningRoles {
        // ARRANGE
        vm.deal(OWNER, OWNER_BALANCE_ONE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(OWNER);
        vm.expectRevert(MultiSigTimelock.MultiSigTimeLock__UserAlreadySigned.selector);
        multiSigTimelock.confirmTransaction(txnId);
    }

    function testConfirmTransactionRevertsIfTransactionDoesNotExists() public grantSigningRoles {
        // ARRANGE
        vm.deal(OWNER, OWNER_BALANCE_ONE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        vm.expectRevert(
            abi.encodeWithSelector(MultiSigTimelock.MultiSigTimelock__TransactionDoesNotExist.selector, txnId + 1)
        );
        multiSigTimelock.confirmTransaction(txnId + 1);
    }

    function testConfirmTransactionRevertsIfNonSigner() public grantSigningRoles {
        // ARRANGE
        address nonSigner = makeAddr("non_owner");
        vm.deal(OWNER, OWNER_BALANCE_ONE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(nonSigner);
        vm.expectRevert();
        multiSigTimelock.confirmTransaction(txnId);
    }

    function testConfirmTransactionRevertsIfTransactionHasExecuted() public grantSigningRoles {
        // ARRANGE
        vm.deal(address(multiSigTimelock), OWNER_BALANCE_TWO);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT & ASSERT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_TWO);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_THREE);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_FOUR);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_FIVE);
        multiSigTimelock.confirmTransaction(txnId);

        vm.prank(OWNER);
        multiSigTimelock.executeTransaction(txnId);

        vm.prank(OWNER);
        vm.expectRevert(abi.encodePacked(MultiSigTimelock.MultiSigTimelock__TransactionAlreadyExecuted.selector, txnId));
        multiSigTimelock.confirmTransaction(txnId);
    }

    // only role tests will be written after i finish the execute function
    /////////////////////////////////////
    /// REVOKE CONFIRMATION TESTS    /////
    /////////////////////////////////////
    function testSignerCanRevokeConfirmation() public grantSigningRoles {
        // ARRANGE
        vm.deal(OWNER, OWNER_BALANCE_ONE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_TWO);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_THREE);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_FOUR);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_FIVE);
        multiSigTimelock.confirmTransaction(txnId);

        vm.prank(OWNER);
        multiSigTimelock.revokeConfirmation(txnId);
        vm.prank(SIGNER_TWO);
        multiSigTimelock.revokeConfirmation(txnId);
        vm.prank(SIGNER_THREE);
        multiSigTimelock.revokeConfirmation(txnId);
        vm.prank(SIGNER_FOUR);
        multiSigTimelock.revokeConfirmation(txnId);
        vm.prank(SIGNER_FIVE);
        multiSigTimelock.revokeConfirmation(txnId);
    }

    function testRevokeConfirmationRevertsIfNotSignedOrAlreadyRevoked() public grantSigningRoles {
        // ARRANGE
        vm.deal(OWNER, OWNER_BALANCE_ONE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        vm.expectRevert(MultiSigTimelock.MultiSigTimeLock__UserHasNotSigned.selector);
        multiSigTimelock.revokeConfirmation(txnId);

        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(OWNER);
        multiSigTimelock.revokeConfirmation(txnId);
        vm.prank(OWNER);
        vm.expectRevert(MultiSigTimelock.MultiSigTimeLock__UserHasNotSigned.selector);
        multiSigTimelock.revokeConfirmation(txnId);
    }

    function testRevokeConfirmationRevertsIfTransactionDoesNotExists() public grantSigningRoles {
        // ARRANGE
        vm.deal(OWNER, OWNER_BALANCE_ONE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);

        vm.prank(OWNER);
        vm.expectRevert(
            abi.encodeWithSelector(MultiSigTimelock.MultiSigTimelock__TransactionDoesNotExist.selector, txnId + 1)
        );
        multiSigTimelock.revokeConfirmation(txnId + 1);
    }

    function testRevokeConfirmationRevertsIfNonSigner() public grantSigningRoles {
        // ARRANGE
        address nonSigner = makeAddr("non_owner");
        vm.deal(OWNER, OWNER_BALANCE_ONE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);

        vm.prank(nonSigner);
        vm.expectRevert();
        multiSigTimelock.revokeConfirmation(txnId);
    }

    function testRevokeConfirmationRevertsIfTransactionHasExecuted() public grantSigningRoles {
        // ARRANGE
        vm.deal(address(multiSigTimelock), OWNER_BALANCE_TWO);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT & ASSERT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_TWO);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_THREE);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_FOUR);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_FIVE);
        multiSigTimelock.confirmTransaction(txnId);

        vm.prank(OWNER);
        multiSigTimelock.executeTransaction(txnId);

        vm.prank(OWNER);
        vm.expectRevert(abi.encodePacked(MultiSigTimelock.MultiSigTimelock__TransactionAlreadyExecuted.selector, txnId));
        multiSigTimelock.revokeConfirmation(txnId);
    }

    ///////////////////////////////////////
    /// EXECUTE TRANSACTION TESTS    /////
    /////////////////////////////////////
    function testExecuteTransactionSuccessfully() public grantSigningRoles {
        // ARRANGE
        // vm.deal(OWNER, OWNER_BALANCE_TWO); //
        vm.deal(address(multiSigTimelock), OWNER_BALANCE_TWO);
        console2.log("OWNER BALANCE: ", OWNER.balance);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_TWO);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_THREE);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_FOUR);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_FIVE);
        multiSigTimelock.confirmTransaction(txnId);

        vm.prank(OWNER);
        multiSigTimelock.executeTransaction(txnId);
    }

    function testExecuteTransactionRevertsIfLessThanTheRequiredConfirmations() public grantSigningRoles {
        // ARRANGE
        // vm.deal(OWNER, OWNER_BALANCE_TWO); //
        vm.deal(address(multiSigTimelock), OWNER_BALANCE_TWO);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_TWO);
        multiSigTimelock.confirmTransaction(txnId);

        vm.prank(OWNER);
        vm.expectRevert(
            abi.encodeWithSelector(
                MultiSigTimelock.MultiSigTimelock__InsufficientConfirmations.selector,
                multiSigTimelock.getRequiredConfirmations(),
                multiSigTimelock.getTransaction(txnId).confirmations
            )
        );
        multiSigTimelock.executeTransaction(txnId);
    }

    function testExecuteTransactionRevertsIfTimelockHasNotExpired() public grantSigningRoles {
        // ARRANGE
        // vm.deal(OWNER, OWNER_BALANCE_TWO); //
        vm.deal(address(multiSigTimelock), OWNER_BALANCE_THREE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_TWO, hex"");

        // ACT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_TWO);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_THREE);
        multiSigTimelock.confirmTransaction(txnId);

        vm.prank(OWNER);
        vm.expectRevert();
        multiSigTimelock.executeTransaction(txnId);
    }

    function testExecuteTransactionRevertsIfExecutionFails() public grantSigningRoles {
        // ARRANGE
        // vm.deal(OWNER, OWNER_BALANCE_TWO); //
        ethRejector = new EthRejector();
        vm.deal(address(multiSigTimelock), OWNER_BALANCE_THREE);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(address(ethRejector), OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_TWO);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_THREE);
        multiSigTimelock.confirmTransaction(txnId);

        vm.prank(OWNER);
        vm.expectRevert(MultiSigTimelock.MultiSigTimelock__ExecutionFailed.selector);
        multiSigTimelock.executeTransaction(txnId);
    }

    function testExecuteTransactionRevertsIfNotEnoughBalance() public grantSigningRoles {
        // ARRANGE
        // vm.deal(OWNER, OWNER_BALANCE_TWO); //
        vm.deal(address(multiSigTimelock), 0);
        vm.prank(OWNER);
        uint256 txnId = multiSigTimelock.proposeTransaction(SPENDER_ONE, OWNER_BALANCE_ONE, hex"");

        // ACT
        vm.prank(OWNER);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_TWO);
        multiSigTimelock.confirmTransaction(txnId);
        vm.prank(SIGNER_THREE);
        multiSigTimelock.confirmTransaction(txnId);

        vm.prank(OWNER);
        vm.expectRevert(
            abi.encodeWithSelector(
                MultiSigTimelock.MultiSigTimelock__InsufficientBalance.selector,
                address(multiSigTimelock).balance
            )
        );
        multiSigTimelock.executeTransaction(txnId);
    }

    ///////////////////////////////
    /// RECEIVE FUNCTION TEST /////
    ///////////////////////////////
    function testReceiveFunction() public {
        // ARRANGE
        vm.deal(OWNER, OWNER_BALANCE_FOUR);

        // ACT
        (bool success,) = address(multiSigTimelock).call{value: OWNER_BALANCE_FOUR}("");
        require(success, "Transfer failed.");

        // ASSERT
        assertEq(address(multiSigTimelock).balance, OWNER_BALANCE_FOUR);
    }

    ///////////////////////////////
    /// TIMELOCKDELAY     TEST /////
    ///////////////////////////////
    function testTimeLockDelayReturnsCorrectValues() public {
        // ARRANGE
        testTimelockDelay = new TestTimelockDelay();
        uint256 sevenDaysTimeDelayAmount = 100 ether;
        uint256 twoDaysTimeDelayAmount = 10 ether;
        // uint256 oneDayTimeDelayAmount = 1 ether;

        // ACT & ASSERT
        assertEq(testTimelockDelay.getTimelockDelay(sevenDaysTimeDelayAmount), multiSigTimelock.getSevenDaysTimeDelay());
        assertEq(testTimelockDelay.getTimelockDelay(twoDaysTimeDelayAmount), multiSigTimelock.getTwoDaysTimeDelay());
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

    function testGetMaxSignerCount() public view {
        // ARRANGE
        uint256 maxSignerCount = 5;

        // ACT & ASSERT
        assertEq(multiSigTimelock.getMaximumSignerCount(), maxSignerCount);
    }
}
