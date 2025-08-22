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
    uint256 private s_oneDayTimeDelay = 24 hours;
    uint256 private s_twoDaysTimeDelay = 48 hours;
    uint256 private s_sevenDaysTimeDelay = 7 days;

    address[] public s_owners;
    mapping(address => bool) public s_isOwner;
    uint256 public s_requiredConfirmations;
    uint256 public s_transactionCount;

    //////////////////////////////////////
    /////// CONSTRUCTOR          /////////
    //////////////////////////////////////
    constructor() Ownable(msg.sender) {}

    //////////////////////////////////////
    ////// RECEIVE FUNCTIONS  ////////////
    //////////////////////////////////////
    receive() external payable {}

    //////////////////////////////////////
    /////// INTERNAL FUNCTIONS    ////////
    //////////////////////////////////////
    // KAYKAY REMEMBER, CONVENTIONALLY, INTERNAL FUNCTIONS ARE PREFIXED WITH AN UNDERSCORE
    function _proposeTransaction(Transaction memory _transaction) internal {}
    function _confirmTransaction(Transaction memory _transaction) internal {}
    function _executeTransaction(Transaction memory _transaction) internal {}
    function _revokeConfirmation(Transaction memory _transaction) internal {}

    
    /////////////////////////////////////////
    /////// EXTERNAL VIEW FUNCTIONS  ////////
    /////////////////////////////////////////
    function getOneDayTimeDelay() external view returns(uint256) {
        return s_oneDayTimeDelay;
    }

    function getTwoDaysTimeDelay() external view returns(uint256) {
        return s_twoDaysTimeDelay;
    }

    function getSevenDaysTimeDelay() external view returns(uint256) {
        return s_SevenDaysTimeDelay;
    }
}
