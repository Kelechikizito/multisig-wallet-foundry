// SPDX-License-Identifier: MIT

// Layout of the contract file:
// version
// imports
// interfaces, libraries, contract
// errors

// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private

// view & pure functions

pragma solidity ^0.8.19;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title MultiSigTimeLock
 * @author Kelechi Kizito Ugwu
 * @dev This is a role-based multisig rather than a signature-based multisig.
 */
contract MultiSigTimelock is Ownable, AccessControl, ReentrancyGuard {
    //////////////////////////////////////
    /////// ERRORS               /////////
    //////////////////////////////////////
    error MultiSigTimelock__AccountIsAlreadyASigner();
    error MultiSigTimelock__MaximumSignersReached();
    error MultiSigTimelock__InvalidAddress();
    error MultiSigTimelock__TransactionDoesNotExist(uint256 transactionId);
    error MultiSigTimelock__TransactionAlreadyExecuted(uint256 transactionId);
    error MultiSigTimeLock__UserAlreadySigned();
    error MultiSigTimeLock__UserHasNotSigned();
    error MultiSigTimelock__ExecutionFailed();
    error MultiSigTimelock__InsufficientConfirmations(uint256 required, uint256 current);
    error MultiSigTimelock__TimelockNotExpired(uint256 expirationTime);

    //////////////////////////////////////
    /////// TYPE DECLARATIONS    /////////
    //////////////////////////////////////
    /// @dev This struct holds the information about a proposed transaction.
    struct Transaction {
        address to; // the recipient of the proposed transaction
        uint256 value; // the amount of ETH to be sent
        bytes data; // The data payload of the transaction if initiated by a smart contract
        uint256 confirmations; // The number of addresses to have signed the transaction thus far
        uint256 proposedAt; // the time(block.timestamp) the transaction was proposed
        bool executed; // boolean representing if the transaction has been executed
    }

    //////////////////////////////////////
    /////// STATE VARIABLES      /////////
    //////////////////////////////////////
    /// @dev Constant for a time delay of 1 day
    uint256 private constant ONE_DAY_TIME_DELAY = 24 hours;
    /// @dev Constant for a time delay of 2 days
    uint256 private constant TWO_DAYS_TIME_DELAY = 48 hours;
    /// @dev Constant for a time delay of 7 days
    uint256 private constant SEVEN_DAYS_TIME_DELAY = 7 days;
    /// @dev Constant for a maximum signer count of 5
    uint256 private constant MAX_SIGNER_COUNT = 5;
    /// @dev Constant for the minimum required number of confirmations to approve a transaction - 3
    uint256 private constant REQUIRED_CONFIRMATIONS = 3;
    bytes32 private constant SIGNING_ROLE = keccak256("SIGNING_ROLE");

    /// @dev State Variable tracks how many signer slots are filled
    uint256 private s_signerCount;
    /// @dev The fixed list of five approved addresses - the five accounts allowed to sign transactions.
    address[5] private s_signers;
    mapping(address user => bool signer) private s_isSigner;
    uint256 private s_transactionCount;
    mapping(uint256 transactionId => Transaction) private s_transactions;
    mapping(uint256 transactionId => mapping(address user => bool userHasSignedCorrectly)) private s_signatures;

    //////////////////////////////////////
    /////// EVENTS               /////////
    //////////////////////////////////////
    event Deposit(address indexed sender, uint256 amount);
    event TransactionProposed(uint256 indexed transactionId, address indexed to, uint256 value);
    event TransactionConfirmed(uint256 indexed transactionId, address indexed signer);
    event TransactionExecuted(uint256 indexed transactionId, address indexed to, uint256 value);
    // event SigningRoleGranted(address indexed account);

    //////////////////////////////////////
    /////// MODIFIERS            /////////
    //////////////////////////////////////
    modifier noneZeroAddress(address account) {
        if (account == address(0)) revert MultiSigTimelock__InvalidAddress();
        _;
    }

    modifier transactionExists(uint256 _transactionId) {
        if (_transactionId >= s_transactionCount) {
            revert MultiSigTimelock__TransactionDoesNotExist(_transactionId);
        }
        _;
    }

    modifier notExecuted(uint256 _transactionId) {
        if (s_transactions[_transactionId].executed) {
            revert MultiSigTimelock__TransactionAlreadyExecuted(_transactionId);
        }
        _;
    }

    // modifier onlySigners() {
    //     if (!hasRole(SIGNING_ROLE, msg.sender)) {
    //         revert MultiSigTimelock__NotASigner();
    //     }
    //     _;
    // }

    //////////////////////////////////////
    /////// CONSTRUCTOR          /////////
    //////////////////////////////////////
    constructor() Ownable(msg.sender) {
        // Automatically add deployer as first signer
        s_signers[0] = msg.sender;
        s_isSigner[msg.sender] = true;
        s_signerCount = 1;

        // Grant signing role to deployer
        _grantRole(SIGNING_ROLE, msg.sender);
    }

    //////////////////////////////////////
    ////// RECEIVE FUNCTIONS  ////////////
    //////////////////////////////////////
    receive() external payable {
        // What should happen when ETH is sent? An Event should be emitted.
        emit Deposit(msg.sender, msg.value);
    }

    //////////////////////////////////////
    /////// EXTERNAL FUNCTIONS    ////////
    //////////////////////////////////////
    /**
     * @dev Function to grant signing role to an account
     * @param _account The address to be granted the signing role
     */
    function grantSigningRole(address _account) external nonReentrant onlyOwner noneZeroAddress(_account) {
        if (s_isSigner[_account]) {
            revert MultiSigTimelock__AccountIsAlreadyASigner();
        }
        if (s_signerCount >= MAX_SIGNER_COUNT) {
            revert MultiSigTimelock__MaximumSignersReached();
        }

        s_signers[s_signerCount] = _account;
        s_isSigner[_account] = true;
        s_signerCount += 1;

        _grantRole(SIGNING_ROLE, _account);
        // emit SigningRoleGranted(_account); // commented this out because the inherited function(_grantRole) emits the event already
    }

    function revokeSigningRole(address _account) external onlyOwner {
        // Write your validation checks here
        // Don't implement the array removal yet - just think through what you need to validate
    }

    /**
     * @dev External function to propose a transaction
     * @param to The address to which the transaction is proposed
     * @param value The amount of ETH to be sent
     * @param data The data payload of the transaction if initiated by a smart contract
     * @return transactionId The ID of the proposed transaction
     */
    function proposeTransaction(address to, uint256 value, bytes calldata data)
        external
        nonReentrant
        noneZeroAddress(to)
        onlyOwner
        returns (uint256)
    {
        return _proposeTransaction(to, value, data);
    }

    /**
     * @dev Function to confirm a transaction
     * @param txnId The ID of the transaction to confirm
     */
    function confirmTransaction(uint256 txnId)
        external
        nonReentrant
        transactionExists(txnId)
        notExecuted(txnId)
        onlyRole(SIGNING_ROLE)
    {
        _confirmTransaction(txnId);
    }

    function revokeConfirmation(uint256 txnId)
        external
        nonReentrant
        transactionExists(txnId)
        notExecuted(txnId)
        onlyRole(SIGNING_ROLE)
    {
        _revokeConfirmation(txnId);
    }

    function executeTransaction(uint256 txnId)
        external
        nonReentrant
        onlyRole(SIGNING_ROLE)
        transactionExists(txnId)
        notExecuted(txnId)
    {
        // Validation checks
        // 1. Check if the transaction has enough confirmations
        // 2. Check if the timelock period has passed
        // 3. Execute the transaction
    }

    //////////////////////////////////////
    /////// INTERNAL FUNCTIONS    ////////
    //////////////////////////////////////
    // KAYKAY REMEMBER, CONVENTIONALLY, INTERNAL FUNCTIONS ARE PREFIXED WITH AN UNDERSCORE
    /**
     * @dev An internal function to propose a transaction
     * @param to The address to which the transaction is proposed
     * @param value The amount of ETH to be sent
     * @param data The data payload of the transaction if initiated by a smart contract
     * @return transactionId The ID of the proposed transaction
     */
    function _proposeTransaction(address to, uint256 value, bytes memory data) internal returns (uint256) {
        uint256 transactionId = s_transactionCount;
        s_transactions[transactionId] = Transaction({
            to: to,
            value: value,
            data: data,
            confirmations: 0,
            proposedAt: block.timestamp,
            executed: false
        });

        s_transactionCount++;
        emit TransactionProposed(transactionId, to, value);
        return transactionId;
    }

    function _confirmTransaction(uint256 txnId) internal {
        // For transaction #123, the mapping might look like:
        // signatures[Alice_address] = true;     // Alice signed ✓
        // signatures[Bob_address] = true;       // Bob signed ✓
        // signatures[Charlie_address] = true;   // Charlie signed ✓
        // signatures[Diana_address] = false;    // Diana hasn't signed yet
        // signatures[Eve_address] = false;      // Eve hasn't signed yet

        if (s_signatures[txnId][msg.sender]) {
            revert MultiSigTimeLock__UserAlreadySigned();
        }
        s_signatures[txnId][msg.sender] = true;

        // Increase counter
        s_transactions[txnId].confirmations++;

        emit TransactionConfirmed(txnId, msg.sender);
    }

    // Internal implementation
    function _executeTransaction(uint256 txnId) internal {
        Transaction storage txn = s_transactions[txnId];

        // 1. Check if enough confirmations
        if (txn.confirmations < REQUIRED_CONFIRMATIONS) {
            revert MultiSigTimelock__InsufficientConfirmations(REQUIRED_CONFIRMATIONS, txn.confirmations);
        }

        // 2. Check if timelock period has passed
        uint256 requiredDelay = _getTimelockDelay(txn.value);
        uint256 executionTime = txn.proposedAt + requiredDelay;
        if (block.timestamp < executionTime) {
            revert MultiSigTimelock__TimelockNotExpired(executionTime);
        }

        // 3. Mark as executed BEFORE the external call (prevent reentrancy)
        txn.executed = true;

        // 4. Execute the transaction
        (bool success,) = txn.to.call{value: txn.value}(txn.data);
        if (!success) {
            revert MultiSigTimelock__ExecutionFailed();
        }

        // 5. Emit event
        emit TransactionExecuted(txnId, txn.to, txn.value);
    }

    function _revokeConfirmation(uint256 txnId) internal {
        if (!s_signatures[txnId][msg.sender]) {
            revert MultiSigTimeLock__UserHasNotSigned();
        }

        // Remove their signature
        s_signatures[txnId][msg.sender] = false;

        // Increase counter
        s_transactions[txnId].confirmations--;
    }

    //////////////////////////////////////////////
    /////// INTERNAL VIEW/PURE FUNCTIONS  ////////
    /////////////////////////////////////////////
    /**
     * @dev An internal pure function to get the timelock delay based on the value of the transaction
     * @param value The amount of ETH to be sent
     * @return The timelock delay in seconds
     */
    function _getTimelockDelay(uint256 value) internal pure returns (uint256) {
        uint256 sevenDaysTimeDelayAmount = 100 ether;
        uint256 twoDaysTimeDelayAmount = 10 ether;
        uint256 oneDayTimeDelayAmount = 1 ether;

        if (value >= sevenDaysTimeDelayAmount) {
            return SEVEN_DAYS_TIME_DELAY;
        } else if (value >= twoDaysTimeDelayAmount) {
            return TWO_DAYS_TIME_DELAY;
        } else if (value >= oneDayTimeDelayAmount) {
            return ONE_DAY_TIME_DELAY;
        } else {
            return 0;
        }
    }

    //////////////////////////////////////////////
    /////// EXTERNAL VIEW/PURE FUNCTIONS  ////////
    /////////////////////////////////////////////
    function getOneDayTimeDelay() external pure returns (uint256) {
        return ONE_DAY_TIME_DELAY;
    }

    function getTwoDaysTimeDelay() external pure returns (uint256) {
        return TWO_DAYS_TIME_DELAY;
    }

    function getSevenDaysTimeDelay() external pure returns (uint256) {
        return SEVEN_DAYS_TIME_DELAY;
    }

    function getMaximumSignerCount() external pure returns (uint256) {
        return MAX_SIGNER_COUNT;
    }

    function getSigningRole() external pure returns (bytes32) {
        return SIGNING_ROLE;
    }

    function getSignerCount() external view returns (uint256) {
        return s_signerCount;
    }

    function getSigners() external view returns (address[5] memory) {
        return s_signers;
    }
}
