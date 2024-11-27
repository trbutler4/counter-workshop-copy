#!/bin/bash
# Abort the script on any error
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $SCRIPT_DIR

# Check for required commands
command -v starkli >/dev/null 2>&1 || { echo >&2 "starkli not found. Aborting."; exit 1; }
command -v scarb >/dev/null 2>&1 || { echo >&2 "scarb not found. Aborting."; exit 1; }

# Validate and source environment variables
if [ ! -f "$SCRIPT_DIR/../.env" ]; then
    echo "Error: .env file not found"
    exit 1
fi
source "$SCRIPT_DIR/../.env"

# Validate required environment variables
: "${INITIAL_VALUE:?INITIAL_VALUE is not set}"
: "${OWNER:?OWNER is not set}"

# Set and validate paths
COUNTER_SIERRA_FILE="$SCRIPT_DIR/../target/dev/workshop_Counter.contract_class.json"

# Build the contract
echo "Building the contract..."
cd "$SCRIPT_DIR/.." || exit 1
scarb build

# Check if build was successful
if [ ! -f "$COUNTER_SIERRA_FILE" ]; then
    echo "Error: Contract file not found after build at $COUNTER_SIERRA_FILE"
    exit 1
fi

# Declaring the contract
echo "Declaring the contract..."
if ! COUNTER_DECLARE_OUTPUT=$(starkli declare --watch "$COUNTER_SIERRA_FILE"); then
    echo "Error: Contract declaration failed"
    exit 1
fi

echo "starkli declare --watch $COUNTER_SIERRA_FILE"
COUNTER_CONTRACT_CLASSHASH=$(echo "$COUNTER_DECLARE_OUTPUT")
echo "Contract class hash: $COUNTER_CONTRACT_CLASSHASH"

# Deploying the contract
echo "Deploying the contract..."
CALLDATA=$(echo -n "$INITIAL_VALUE" "$OWNER")
echo "starkli deploy $COUNTER_CONTRACT_CLASSHASH $CALLDATA"

if ! COUNTER_DEPLOY_OUTPUT=$(starkli deploy $COUNTER_CONTRACT_CLASSHASH $CALLDATA); then
    echo "Error: Contract deployment failed"
    exit 1
fi
echo "$COUNTER_DEPLOY_OUTPUT"

# Extract the contract address
COUNTER_CONTRACT_ADDRESS=$(echo "$COUNTER_DEPLOY_OUTPUT" | grep -oE '0x[0-9a-fA-F]{64}')

if [ -z "$COUNTER_CONTRACT_ADDRESS" ]; then
    echo "Error: Failed to retrieve Counter contract address"
    exit 1
fi
