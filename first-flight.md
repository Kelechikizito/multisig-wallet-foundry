# Protocol Name 
Timelock Multi-Signature Wallet

### Prize Pool TO BE FILLED OUT BY CYFRIN

- Total Pool - 
- H/M -  
- Low - 

- Starts: 
- Ends: 

- nSLOC: 

[//]: # (contest-details-open)

## About the Project

This project is a secure, role-based multi-signature wallet with a built-in dynamic timelock mechanism, designed to add an extra layer of protection and governance for Ethereum funds, especially when dealing with large transaction amounts.

The core idea is to combine the safety of traditional multi-signature requirements (minimum 3 out of up to 5 signers) with a value-based timelock that automatically enforces longer delay periods as the amount of ETH involved increases. This prevents rushed or potentially compromised high-value transfers while keeping small, everyday transactions fast and frictionless.

Key features:
- Up to 5 designated signers with granular role-based access control (via OpenZeppelin AccessControl)
- Requires at least 3 confirmations to execute any transaction
- Dynamic timelock:
  - < 1 ETH → no delay (immediate execution possible)
  - 1–10 ETH → 1-day delay
  - 10–100 ETH → 2-day delay
  - ≥ 100 ETH → 7-day delay
- Transparent proposal → confirmation → execution workflow with events
- Easy state inspection via public getters

[GitHub Repository](https://github.com/Kelechikizito/multisig-wallet-foundry)

## Actors

### Contract Owner (Deployer)
- The account that deploys the `MultiSigTimelock` contract.
- Automatically receives both the OpenZeppelin `DEFAULT_ADMIN_ROLE` and the custom `SIGNING_ROLE`, becoming the first signer.
- **Powers**:
  - Propose new transactions (recipient, value, data)
  - Grant the `SIGNING_ROLE` to additional addresses (up to a maximum of 5 total signers)
  - Revoke the `SIGNING_ROLE` from any signer except when it would drop the total below 1 (prevents bricking the wallet)
  - As a signer, can confirm transactions, revoke own confirmations, and execute transactions once quorum and timelock are satisfied
- **Limitations**:
  - Cannot unilaterally execute transactions — still requires 2 additional confirmations (minimum 3-of-N)
  - Cannot remove the last remaining signer
  - Cannot bypass the timelock delays for large transactions

### Signers (holders of SIGNING_ROLE)
- Up to 5 addresses in total (owner + up to 4 others) that possess the `SIGNING_ROLE`.
- **Powers**:
  - Confirm pending transaction proposals
  - Revoke their own previous confirmation (useful if they change their mind before execution)
  - Execute a transaction once:
    - At least 3 distinct signers have confirmed, and
    - The value-based timelock period has fully elapsed
  - Propose new transactions (permission is tied to the role, so any signer can propose)
- **Limitations**:
  - Cannot grant or revoke roles — only the owner (admin) can manage membership
  - Cannot execute a transaction without meeting the 3-confirmation quorum and timelock requirement
  - No individual signer has more power than any other once the role is granted


[//]: # (contest-details-close)

[//]: # (scope-open)

## Scope (contracts)

All Contracts in `src` are in scope.

```js
src/
├── MultiSigTimelock.sol
```

## Compatibilities

Compatibilities:
  Blockchains:
      - Ethereum/Any EVM

[//]: # (scope-close)

[//]: # (getting-started-open)

## Setup

Build:
```bash
foundryup

forge build

forge install OpenZeppelin/openzeppelin-contracts
```

Tests:
```bash
forge test
```

[//]: # (getting-started-close)

[//]: # (known-issues-open)

## Known Issues

- Floating Solidity compiler version.
  
```javascript
pragma solidity ^0.8.19;
```

[//]: # (known-issues-close)