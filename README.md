# Starknet Counter App

This is a simple counter app used during Basecamp to teach how to create a smart contract, deploy it, test it and build a UI for it.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Starkli](https://github.com/xJonathanLEI/starkli) - Starknet CLI tool
- A Unix-like environment (Linux/MacOS, or WSL for Windows)

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd completed-counter-app
```

2. Create a `.env` file in the project root with the following variables:
```env
INITIAL_VALUE=<your-initial-counter-value>
OWNER=<your-wallet-address>
```

Example:
```env
INITIAL_VALUE=42
OWNER=0x123...abc
```

### 3. Configure Starkli

Starkli requires specific environment variables to interact with Starknet. You'll need to set up:

#### a. Create and Fund a Starknet Account
1. Create a new keystore file:
```bash
starkli signer keystore new ~/.starkli-wallets/deployer/keystore.json
```

2. Create a new Starknet account:
```bash
starkli account oz init ~/.starkli-wallets/deployer/account.json
```

3. Fund your account with ETH on Sepolia (using a faucet)

#### b. Set Environment Variables
Add these to your `~/.zshrc` or `~/.bashrc`:

```bash
# Starknet Account
export STARKNET_ACCOUNT=~/.starkli-wallets/deployer/account.json
export STARKNET_KEYSTORE=~/.starkli-wallets/deployer/keystore.json

# Starknet RPC
export STARKNET_RPC=https://starknet-sepolia.blastapi.io/ab914dde-4484-4558-9c2b-bf20aa43c1a3/rpc/v0_7
```

Then reload your shell:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

#### c. Verify Configuration
Test your setup:
```bash
starkli balance <your-account-address>
```

## Deployment

1. Make the deployment script executable:
```bash
chmod +x scripts/sepolia_deploy.sh
```

2. Run the deployment script:
```bash
./scripts/sepolia_deploy.sh
```

### 4. Using starknet foundry 
