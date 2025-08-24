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
 */
contract MultiSigTimelock is Ownable, AccessControl, ReentrancyGuard {
    //////////////////////////////////////
    /////// ERRORS               /////////
    //////////////////////////////////////
    error MultiSigTimelock__AccountIsAlreadyAnOwner();
    error MultiSigTimelock__MaximumOwnersReached();
    error MultiSigTimelock__InvalidAddress();

    //////////////////////////////////////
    /////// TYPE DECLARATIONS    /////////
    //////////////////////////////////////
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        uint256 confirmations;
        uint256 proposedAt;
        bool executed;
        mapping(address user => bool userHasSignedCorrectly) signatures;
    }

    //////////////////////////////////////
    /////// STATE VARIABLES      /////////
    //////////////////////////////////////
    uint256 private constant ONE_DAY_TIME_DELAY = 24 hours;
    uint256 private constant TWO_DAYS_TIME_DELAY = 48 hours;
    uint256 private constant SEVEN_DAYS_TIME_DELAY = 7 days;
    uint256 private constant MAX_OWNER_COUNT = 5;
    bytes32 private constant SIGNING_ROLE = keccak256("SIGNING_ROLE");

    uint256 private s_requiredConfirmations = 3; // 3 out of 5 owners to approve a transaction.
    address[5] private s_owners; // The list of approved addresses (the people allowed to sign transactions).
    mapping(address user => bool owner) private s_isOwner;
    uint256 private s_ownerCount; // This variable tracks how many slots are filled
    mapping(uint256 transactionId => Transaction) private s_transactions;
    uint256 private s_transactionCount;

    //////////////////////////////////////
    /////// EVENTS               /////////
    //////////////////////////////////////
    event Deposit(address indexed sender, uint256 amount);
    event SigningRoleGranted(address indexed account);

    //////////////////////////////////////
    /////// MODIFIERS            /////////
    //////////////////////////////////////
    modifier noneZeroAddress(address account) {
        if (account == address(0)) revert MultiSigTimelock__InvalidAddress();
        _;
    }

    //////////////////////////////////////
    /////// CONSTRUCTOR          /////////
    //////////////////////////////////////
    constructor() Ownable(msg.sender) {}

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
    function grantSigningRole(address _account) external onlyOwner noneZeroAddress(_account) {
        if (s_isOwner[_account]) {
            revert MultiSigTimelock__AccountIsAlreadyAnOwner();
        }
        if (s_ownerCount >= MAX_OWNER_COUNT) {
            revert MultiSigTimelock__MaximumOwnersReached();
        }

        s_owners[s_ownerCount] = _account;
        s_isOwner[_account] = true;
        s_ownerCount += 1;

        _grantRole(SIGNING_ROLE, _account);
        emit SigningRoleGranted(_account);
    }

    /**
     * @dev Function to propose a transaction
     * @param to
     * @param value
     * @param data
     */
    function proposeTransaction(address to, uint256 value, bytes calldata data) external nonReentrant {
        _proposeTransaction(to, value, data);
    }

    //////////////////////////////////////
    /////// INTERNAL FUNCTIONS    ////////
    //////////////////////////////////////
    // KAYKAY REMEMBER, CONVENTIONALLY, INTERNAL FUNCTIONS ARE PREFIXED WITH AN UNDERSCORE
    function _proposeTransaction(address to, uint256 value, bytes memory data) internal {}

    function _confirmTransaction(address to, uint256 value, bytes memory data) internal {}

    function _executeTransaction(address to, uint256 value, bytes memory data) internal {}

    function _revokeConfirmation(address to, uint256 value, bytes memory data) internal {}

    /////////////////////////////////////////
    /////// EXTERNAL VIEW FUNCTIONS  ////////
    /////////////////////////////////////////
    function getOneDayTimeDelay() external pure returns (uint256) {
        return ONE_DAY_TIME_DELAY;
    }

    function getTwoDaysTimeDelay() external pure returns (uint256) {
        return TWO_DAYS_TIME_DELAY;
    }

    function getSevenDaysTimeDelay() external pure returns (uint256) {
        return SEVEN_DAYS_TIME_DELAY;
    }
}
