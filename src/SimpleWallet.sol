// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// /**
//  * @title SimpleWallet
//  * @dev A simple wallet contract with owner-only withdraw functionality
//  * @notice This contract allows the owner to deposit and withdraw ETH
//  */
// contract SimpleWallet {
//     address public owner;

//     // Events for better tracking and debugging
//     event Deposit(address indexed sender, uint256 amount);
//     event Withdrawal(address indexed owner, uint256 amount);
//     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

//     // Custom errors for gas efficiency
//     error NotOwner();
//     error InsufficientFunds();
//     error TransferFailed();
//     error ZeroAddress();
//     error ZeroAmount();

//     modifier onlyOwner() {
//         if (msg.sender != owner) revert NotOwner();
//         _;
//     }

//     modifier nonZeroAmount(uint256 _amount) {
//         if (_amount == 0) revert ZeroAmount();
//         _;
//     }

//     /**
//      * @dev Set the owner when contract is deployed
//      */
//     constructor() {
//         owner = msg.sender;
//         emit OwnershipTransferred(address(0), msg.sender);
//     }

//     /**
//      * @dev Allow the contract to receive ETH and emit deposit event
//      */
//     receive() external payable {
//         emit Deposit(msg.sender, msg.value);
//     }

//     /**
//      * @dev Explicit deposit function with event emission
//      */
//     function deposit() external payable {
//         emit Deposit(msg.sender, msg.value);
//     }

//     /**
//      * @dev Function for the owner to withdraw ETH
//      * @param _amount The amount of ETH to withdraw in wei
//      */
//     function withdraw(uint256 _amount) external onlyOwner nonZeroAmount(_amount) {
//         if (_amount > address(this).balance) revert InsufficientFunds();

//         // Use call for better gas efficiency and security
//         (bool success,) = payable(owner).call{value: _amount}("");
//         if (!success) revert TransferFailed();

//         emit Withdrawal(owner, _amount);
//     }

//     /**
//      * @dev Function for the owner to withdraw all ETH
//      */
//     function withdrawAll() external onlyOwner {
//         uint256 contractBalance = address(this).balance;
//         if (contractBalance == 0) revert ZeroAmount();

//         (bool success,) = payable(owner).call{value: contractBalance}("");
//         if (!success) revert TransferFailed();

//         emit Withdrawal(owner, contractBalance);
//     }

//     /**
//      * @dev Transfer ownership to a new address
//      * @param _newOwner The address of the new owner
//      */
//     function transferOwnership(address _newOwner) external onlyOwner {
//         if (_newOwner == address(0)) revert ZeroAddress();

//         address previousOwner = owner;
//         owner = _newOwner;

//         emit OwnershipTransferred(previousOwner, _newOwner);
//     }

//     /**
//      * @dev Function to check balance of the wallet
//      * @return The current ETH balance of the contract
//      */
//     function getBalance() external view returns (uint256) {
//         return address(this).balance;
//     }

//     /**
//      * @dev Emergency function to recover accidentally sent ERC20 tokens
//      * @param _token The address of the ERC20 token contract
//      * @param _amount The amount of tokens to recover
//      */
//     function recoverERC20(address _token, uint256 _amount) external onlyOwner {
//         if (_token == address(0)) revert ZeroAddress();
//         if (_amount == 0) revert ZeroAmount();

//         // Simple ERC20 transfer call
//         (bool success, bytes memory data) =
//             _token.call(abi.encodeWithSignature("transfer(address,uint256)", owner, _amount));

//         // Check if the call was successful and returned true (or no data)
//         if (!success || (data.length > 0 && !abi.decode(data, (bool)))) {
//             revert TransferFailed();
//         }
//     }
// }
