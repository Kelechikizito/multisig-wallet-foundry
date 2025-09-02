# Multi-Signature Wallet Timelock 

This project has been built as a personal mini-project, and it is a role-based, multi-signature wallet with a timelock functionality built with Open Zeppelin's Role-Based Access-Control(RBAC).

The timelock functionality kicks in with increasing amount of ETH to be sent in a transaction.

A live 'unverified' contract address with Ethereum Sepolia testnet is available at [contract address](https://sepolia.etherscan.io/address/0x34da08fbaed3814e8c71691641ef0ad4fe0b7fde).

## Table of Contents

- [Multi-Signature Wallet Timelock](#multi-signature-wallet-timelock)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Role-Based Multi-Signature Wallets](#role-based-multi-signature-wallets)
  - [Contracts/Architecture](#contractsarchitecture)
  - [System Actors](#system-actors)
  - [OpenZeppelin Integrations](#openzeppelin-integrations)
    - [Ownable](#ownable)
    - [AccessControl](#accesscontrol)
    - [ReentrancyGuard](#reentrancyguard)
  - [Transaction Flows](#transaction-flows)
  - [Deploying](#deploying)
    - [LINK Token Funding](#link-token-funding)

## Overview

**Problem statement**: "Securely managing multi-signature transactions on Ethereum requires a robust mechanism to ensure consensus among multiple parties while mitigating risks such as unauthorized access, premature execution, or reentrancy attacks. Traditional multi-signature wallets may lack flexible timelock mechanisms to delay high-value transactions, increasing the risk of hasty or malicious executions."

**Solution**: The `MultiSigTimelock` contract implements a role-based multi-signature wallet with a dynamic timelock feature. It allows up to five signers, requiring at least three confirmations to execute a transaction. The timelock duration varies based on transaction value: no delay for transactions below 1 ETH, 1 day for 1-10 ETH, 2 days for 10-100 ETH, and 7 days for 100 ETH and above. This ensures higher scrutiny for larger transactions. 

The contract leverages OpenZeppelin's `Ownable`, `AccessControl`, and `ReentrancyGuard` to enforce ownership, role-based permissions, and protection against reentrancy attacks. Transactions are proposed, confirmed, and executed in a secure, transparent manner, with events emitted for tracking and getters for querying state.

## Role-Based Multi-Signature Wallets

Multi-signature (multisig) wallets enhance security by requiring multiple approvals before executing transactions on blockchain networks like Ethereum. They typically follow standards such as [ERC-1271](https://eips.ethereum.org/EIPS/eip-1271) for signature validation and integrate with modules like timelocks for delayed execution. Popular implementations, such as Gnosis Safe, are modular and permissioned, allowing customizable signer thresholds (e.g., m-of-n approvals) to prevent single-point failures. Advanced features include batched transactions via `execTransaction` and gas-efficient role management, reducing risks from key loss or compromise. See [Gnosis Safe contracts](https://github.com/safe-global/safe-contracts).

## Contracts/Architecture

The MultiSigTimelock system implements a role-based multi-signature wallet with integrated timelock delays for secure transaction management on Ethereum. The `MultiSigTimelock` contract serves as the core component, handling all aspects of transaction proposal, confirmation, revocation, and execution while enforcing security through inherited OpenZeppelin modules like `Ownable` for ownership control, `AccessControl` for role management, and `ReentrancyGuard` to prevent reentrancy attacks.

The contract owner (deployer by default) proposes transactions by specifying a recipient address, ETH value, and optional data payload. In exchange, a unique transaction ID is generated, and the transaction enters a pending state. Approved signers (up to a maximum of 5, with at least 3 required confirmations) can then confirm or revoke their approval for the transaction. The timelock delay is dynamically applied based on the transaction's value: no delay for under 1 ETH, 1 day for 1-10 ETH, 2 days for 10-100 ETH, and 7 days for 100 ETH or more. Once sufficient confirmations are met and the timelock expires, any signer can execute the transaction, transferring the specified ETH (and calling any data if provided) while emitting events for transparency. The owner also manages signer roles by granting or revoking the `SIGNING_ROLE`, ensuring only authorized accounts participate.

This architecture prioritizes security and consensus, with all logic contained in a single contract to minimize complexity and attack surfaces. See [./src/MultiSigTimelock.sol](https://github.com/Kelechikizito/multisig-wallet-foundry/blob/master/src/MultiSigTimelock.sol).

## System Actors

The primary actors in this system are the contract owner and the signers, who collectively manage and execute transactions.

**Contract Owner** deploys the contract and automatically becomes the first signer. They can propose new transactions (specifying recipient, value, and data), grant signing roles to additional accounts (up to a maximum of 5 total signers), and revoke signing roles from existing signers (except the last one to maintain functionality).

**Signers** hold the SIGNING_ROLE and include the owner plus up to 4 additional approved accounts. They can confirm proposed transactions to build the required consensus (minimum 3 confirmations), revoke their own confirmations if needed, and execute confirmed transactions once the value-based timelock period has expired.

## OpenZeppelin Integrations

OpenZeppelin libraries provide secure, audited primitives for access management and vulnerability prevention in the MultiSigTimelock contract. Ownable, AccessControl, and ReentrancyGuard are combined to handle ownership, role-based signing, and reentrancy protection, ensuring the multisig operates safely without single points of failure.

### Ownable

Ownable provides basic authorization control, designating a single owner (typically the deployer) who can manage signer roles and initiate transaction proposals.

The constructor initializes the owner with `Ownable(msg.sender)`. Administrative functions such as `grantSigningRole` and `revokeSigningRole` for adding/removing signers, and `proposeTransaction` for submitting new transactions, are restricted via the `onlyOwner` modifier.

### AccessControl

AccessControl enables granular role management, specifically through the `SIGNING_ROLE` which authorizes up to five signers to participate in transaction approvals.

The role is granted/revoked using `_grantRole` and `_revokeRole` in `grantSigningRole` and `revokeSigningRole`. Core operations like `confirmTransaction`, `revokeConfirmation`, and `executeTransaction` are protected by the `onlyRole(SIGNING_ROLE)` modifier, allowing confirmed signers to interact while enforcing the required confirmation threshold.

### ReentrancyGuard

ReentrancyGuard prevents recursive call attacks by locking functions during execution, safeguarding the contract's state during external interactions.

The `nonReentrant` modifier is applied to all external mutable functions, including `grantSigningRole`, `revokeSigningRole`, `proposeTransaction`, `confirmTransaction`, `revokeConfirmation`, and `executeTransaction`, ensuring safe handling of ETH transfers and state updates without reentrancy risks.

## Transaction Flows

## Deploying

The `MultiSigTimelock` (`DeployMultiSigTimelock`) should be deployed first. This script will also deploy the `ParentRebalancer`, and YieldCoin `Share` and `SharePool` contracts, as well as call the necessary functions to make the pool permissionless and integrate it with CCIP. It also grants mint and burn roles for YieldCoin to the `ParentPeer` and CCIP pool, as well as setting storage in `ParentRebalancer`.

```
forge script script/DeployMultiSigTimelock.s.sol:DeployMultiSigTimelock --broadcast --account <YOUR_FOUNDRY_KEYSTORE> --rpc-url <PARENT_CHAIN_RPC_URL> -vvvv
```

The Chainlink Automation forwarder address should be set in `ParentRebalancer::setForwarder()` and the Chainlink Automation upkeep address should be set in `ParentCLF::setUpkeepAddress()`.

The `ParentCLF`, `Share`, and `SharePool` addresses returned from running that script should be added to `NetworkConfig.peers` for both the Parent chain and any child chains.

Next deploy the `ChildPeer` and its YieldCoin `Share` and `SharePool` contracts. This will also perform the necessary actions to enable permissionless CCIP pool functionality and grant appropriate mint and burn roles for `YieldCoin`. This script should be run for every child chain.

```
forge script script/deploy/DeployChild.s.sol --broadcast --account <YOUR_FOUNDRY_KEYSTORE> --rpc-url <CHILD_CHAIN_RPC_URL>
```

For every deployed Child, take the `ChildPeer`, `Share`, and `SharePool` addresses and add them to the `NetworkConfig.peer` for all applicable chains, including the Parent.

Finally run the [`SetCrosschain`](https://github.com/contractlevel/yield/blob/main/script/interactions/SetCrosschain.s.sol) script for every chain. This will set the allowed chain selectors and peers for each chain, as well as enable the CCIP pools to work with each other.

```
forge script script/interactions/SetCrosschain.s.sol --broadcast --account <YOUR_FOUNDRY_KEYSTORE> --rpc-url <CHAIN_RPC_URL>
```

### LINK Token Funding

For the Contract Level Yield infrastructure to function, LINK is required for the following:

- Time-based Automation subscription on Parent chain
- Log-trigger Automation subscription on Parent chain
- Chainlink Functions subscription on Parent chain
- Every `YieldPeer` on every chain for CCIP txs