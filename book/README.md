# Blockchain Budget Planner

A decentralized budget planning application built on the Stacks blockchain using Clarity smart contracts.

## Overview

This project implements a budget planning system where users can:
- Set savings goals and budgets
- Track expenses by category
- Create alerts when approaching spending limits
- Visualize spending patterns (via frontend integration)

All data is stored securely on the Stacks blockchain, providing transparency, security, and immutability for financial records.

## Technical Stack

- **Smart Contract Language**: Clarity
- **Blockchain**: Stacks
- **Development Environment**: Clarinet
- **Version Control**: Git

## Project Structure

```
budget-planner/
├── contracts/
│   └── budget-planner.clar       # Main smart contract
├── tests/
│   └── budget-planner_test.ts    # Contract tests
├── Clarinet.toml                 # Project configuration
├── .gitignore
└── README.md                     # This file
```

## Smart Contract Details

The main contract (`budget-planner.clar`) contains the following core functionality:

1. **Budget Management**:
   - Initialize user budgets
   - Set spending categories and allocations
   - Record expenses
   - Check remaining budgets

2. **Alert System**:
   - Create threshold alerts for categories
   - Activate/deactivate alerts

3. **Data Structures**:
   - User budgets map
   - Category allocations
   - Alert configurations

## Getting Started

### Prerequisites

1. Install the Stacks CLI and Clarinet:
   ```bash
   npm install -g @stacks/cli
   npm install -g @hirosystems/clarinet
   ```

2. Install Git for version control.

### Project Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/midorichie/blockchain-budget-planner.git
   cd blockchain-budget-planner
   ```

2. Initialize a new Clarinet project (if starting from scratch):
   ```bash
   clarinet new blockchain-budget-planner
   cd blockchain-budget-planner
   ```

3. Add the smart contract to your project:
   ```bash
   clarinet contract new budget-planner
   ```
   Then copy the contract code into `contracts/budget-planner.clar`.

### Running Tests

Execute the test suite:
```bash
clarinet test
```

## Contract Deployment

To deploy to the Stacks testnet:

1. Generate a new keychain:
   ```bash
   stx make_keychain -t
   ```

2. Request testnet STX from the faucet.

3. Deploy the contract:
   ```bash
   clarinet deploy --testnet
   ```

## Usage Examples

### Initialize a User Budget

```clarity
(contract-call? .budget-planner initialize-budget u1 u10000)
```
This initializes a budget of 10,000 microSTX for user ID 1.

### Add a Spending Category

```clarity
(contract-call? .budget-planner add-category-allocation u1 "groceries" u3000)
```
This allocates 3,000 microSTX to the "groceries" category for user ID 1.

### Record Spending

```clarity
(contract-call? .budget-planner record-spending u1 "groceries" u500)
```
This records a 500 microSTX expense in the "groceries" category.

### Create a Budget Alert

```clarity
(contract-call? .budget-planner add-budget-alert u1 "groceries" u80)
```
This creates an alert that triggers when 80% of the groceries budget is spent.

## Security Considerations

- The contract implements access controls to ensure only authorized users can modify their own budgets
- Integer overflow protection is built into Clarity
- The contract avoids reentrancy vulnerabilities by design

## Future Enhancements

1. Integration with STX transfers for actual fund management
2. Multi-signature budget approval for shared finances
3. Time-locked budgets for periodic allowances
4. Enhanced analytics for spending patterns

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please contact [hamsohood@gmail.com].
