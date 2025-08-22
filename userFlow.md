# User Flow: Multi-Signature Wallet with Time Locks

Let me walk you through how users would actually interact with this wallet step-by-step.

## Setup Phase (One-time)

**1. Wallet Creation**
```
Admin → Deploys contract → Sets 5 owners → Requires 3 signatures
```
- Alice, Bob, Charlie, Diana, and Eve are the 5 wallet owners
- Any transaction needs 3 out of 5 signatures to execute
- Time delays: >10 ETH = 48 hours, >1 ETH = 24 hours, <1 ETH = instant

## Daily Transaction Flow

### **Scenario 1: Small Transaction (0.5 ETH)**

**Step 1: Proposal**
```
Alice wants to send 0.5 ETH to pay contractor
Alice → Calls proposeTransaction(contractorAddress, 0.5 ETH, "")
Contract → Creates Transaction ID #123
```

**Step 2: Signatures**
```
Bob → Signs transaction #123 (1/3 signatures)
Charlie → Signs transaction #123 (2/3 signatures) 
Diana → Signs transaction #123 (3/3 signatures ✓)
```

**Step 3: Immediate Execution**
```
Anyone → Calls executeTransaction(123)
Contract → Checks: 3 signatures ✓, amount <1 ETH ✓, no timelock needed
Transaction → Executes immediately, 0.5 ETH sent
```

### **Scenario 2: Large Transaction (15 ETH)**

**Step 1: Proposal**
```
Alice → Proposes sending 15 ETH to exchange
Contract → Creates Transaction #124, timestamp = now
```

**Step 2: Signatures**
```
Bob → Signs #124 (1/3)
Charlie → Signs #124 (2/3)
Diana → Signs #124 (3/3 signatures met ✓)
```

**Step 3: Time Lock Enforced**
```
Anyone → Tries to execute #124
Contract → "Wait! 15 ETH > 10 ETH threshold"
Contract → "Must wait 48 hours from proposal time"
Contract → Current status: "Pending, executable in 47 hours, 23 minutes"
```

**Step 4: Waiting Period**
```
⏰ 48 hours pass...
Anyone → Calls executeTransaction(124)
Contract → Checks: 3 signatures ✓, 48 hours passed ✓
Transaction → Executes, 15 ETH sent
```

## User Interface Flow

### **Web Dashboard View**

**Pending Transactions Tab:**
```
ID #124: Send 15 ETH to 0x123...abc
Status: ⏰ Waiting (6 hours remaining)
Signatures: ✓ Alice ✓ Bob ✓ Charlie ❌ Diana ❌ Eve
Your Action: [Already Signed] 
```

**Transaction History:**
```
✅ #123: 0.5 ETH sent (Instant) - 2 days ago
⏰ #124: 15 ETH pending (6h left) - 2 days ago  
❌ #122: 2 ETH cancelled - 3 days ago
```

## Edge Cases & User Scenarios

### **Scenario 3: Transaction Gets Cancelled**

**During Waiting Period:**
```
Day 1: Alice proposes 20 ETH withdrawal
Day 1: Bob, Charlie, Diana sign (3/3 met)
Day 2: Team realizes it's a mistake
Charlie → Calls revokeConfirmation(124)
Result: Back to 2/3 signatures, transaction can't execute
```

### **Scenario 4: Emergency Override**

**Critical Situation:**
```
Exchange hack detected! Need to move funds NOW
Eve (emergency admin) → Calls emergencyExecute(125)
Contract → Bypasses timelock for designated emergency admin
All funds → Moved to cold storage immediately
```

### **Scenario 5: Signature Collection**

**Real-world coordination:**
```
Alice: "I proposed transaction #126 in our group chat"
Bob: "I'll sign when I get home"
Charlie: "Signed! ✓"  
Diana: "What's this for? Need more details"
Alice: "It's for the new office deposit, check the memo"
Diana: "Got it, signing now ✓"
```

## Mobile App Flow

**Notification:**
```
📱 "New transaction proposed: 5 ETH to supplier"
   [View Details] [Sign] [Ignore]
```

**Signing Process:**
```
User opens app → Face ID/Touch ID → Review transaction details
→ [Confirm Signature] → "Signed! 2/3 signatures collected"
```

## What Users See vs. What Happens Behind the Scenes

### **User sees:**
- "Transaction pending approval (2/3 signatures)"
- "Will execute in 23 hours, 15 minutes"
- Simple [Sign] or [Execute] buttons

### **Contract does:**
- Validates each signature cryptographically
- Tracks timestamps precisely
- Prevents double-signing
- Calculates exact execution times
- Manages complex state transitions

## Key User Benefits

**Security:** "Even if 2 people get hacked, funds are safe"
**Transparency:** "Everyone sees what's happening"
**Control:** "Big moves need consensus AND time to think"
**Flexibility:** "Small payments don't get delayed"

This flow makes complex crypto security feel as simple as "propose → sign → wait → execute" while handling all the cryptographic complexity behind the scenes.

Does this help clarify how users would actually interact with your multisig wallet?