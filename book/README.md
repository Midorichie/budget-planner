# Budget Planner Smart Contract System

A comprehensive budget planning and analytics system built for the Stacks blockchain.

## Overview

This project provides a full-featured budget management system that allows users to:

- Create and manage personal budgets
- Allocate funds to specific spending categories
- Track spending against allocations
- Receive alerts when nearing budget thresholds
- Analyze spending patterns over time
- Set and track savings goals

## Key Features

### Budget Planner Contract

- **User Registration**: Create unique identifiers for users
- **Budget Creation**: Initialize and customize budgets
- **Category Management**: Create and manage spending categories
- **Spending Tracking**: Record and monitor expenditures
- **Budget Alerts**: Get notifications when approaching spending limits
- **Permission Management**: Control who can access and modify your budget
- **Activity Logging**: Maintain a complete audit trail of all budget activities
- **Budget Status Control**: Activate, freeze, or close budgets as needed

### Budget Analytics Contract

- **Historical Spending**: Track spending patterns over time
- **Savings Goals**: Create and track progress toward savings targets
- **Performance Metrics**: Calculate budget adherence and other metrics
- **Spending Trends**: Visualize spending changes over time
- **Cross-Contract Integration**: Seamless interaction between contracts

## Security Features

- **Permission-Based Access Control**: Fine-grained permissions for reading, writing, and administration
- **Activity Logging**: Complete audit trail of all budget operations
- **Status Management**: Ability to freeze budgets in case of security concerns
- **Error Handling**: Comprehensive error codes and validation
- **Owner Controls**: Contract ownership with transfer capabilities

## Technical Details

The system consists of two primary smart contracts:

1. **Budget Planner Contract**: Core budget management functionality
2. **Budget Analytics Contract**: Extended analytics and goal tracking

These contracts use traits for interoperability, allowing them to securely communicate with each other.

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic understanding of [Clarity](https://clarity-lang.org/) and the Stacks blockchain

### Installation

1. Clone this repository
```bash
git clone https://github.com/midorichie/budget-planner.git
cd budget-planner
```

2. Install dependencies
```bash
npm install
```

3. Run tests
```bash
clarinet test
```

## Usage

### Creating a New Budget

```clarity
(contract-call? .budget-planner initialize-budget u1 u10000)
```

### Adding a Category

```clarity
(contract-call? .budget-planner add-category-allocation u1 "groceries" u3000)
```

### Recording Spending

```clarity
(contract-call? .budget-planner record-spending u1 "groceries" u50)
```

### Setting a Savings Goal

```clarity
(contract-call? .budget-analytics create-savings-goal u1 "Vacation" u5000 u1672531200)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Stacks Foundation
- Clarity language documentation
- The entire Stacks community
