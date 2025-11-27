#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Get the absolute path of the script's directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Check and install required dependencies
echo "Checking required dependencies..."
REQUIRED_PACKAGES=("jq" "unzip" "wget")
MISSING_PACKAGES=()

for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! command -v "$package" &> /dev/null; then
        MISSING_PACKAGES+=("$package")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo -e "${GREEN}Installing missing dependencies: ${MISSING_PACKAGES[*]}...${NC}"
    if sudo apt update && sudo apt install -y "${MISSING_PACKAGES[@]}"; then
        echo -e "${GREEN}Dependencies installed successfully.${NC}"
    else
        echo -e "${RED}Error: Failed to install dependencies. Please install manually:${NC}"
        echo -e "${RED}sudo apt update && sudo apt install -y ${MISSING_PACKAGES[*]}${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}All required dependencies are already installed.${NC}"
fi

# Check if a coin argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Missing argument. Please specify a coin.${NC}"
    echo -e "${RED}Usage: $0 {btc|ltc} [host:port:ssl|nossl] ...${NC}"
    exit 1
fi

MINER=$1
shift

if [ "$MINER" != "btc" ] && [ "$MINER" != "ltc" ]; then
    echo -e "${RED}Error: Invalid coin specified. Please use 'btc' or 'ltc'.${NC}"
    echo -e "${RED}Usage: $0 {btc|ltc} [host:port:ssl|nossl] ...${NC}"
    exit 1
fi

AGENT_DIR="$SCRIPT_DIR/${MINER}_mineragent"
CONFIG_FILE="$AGENT_DIR/conf/config.json"

# Check if the directory for the specified miner exists
if [ ! -d "$AGENT_DIR" ]; then
    echo -e "${RED}Error: Miner agent for '$MINER' not found at $AGENT_DIR${NC}"
    exit 1
fi

# Parse stratum server arguments if any are provided
if [ "$#" -gt 0 ]; then
    servers_json=""
    for server_arg in "$@"; do
            IFS=':' read -r host port ssl_str <<< "$server_arg"

            # Basic format check
            if [ -z "$host" ] || [ -z "$port" ] || [ -z "$ssl_str" ]; then
                echo -e "${RED}Error: Invalid stratum server format. Use host:port:ssl|nossl${NC}"
                exit 1
            fi

            # Host validation (simple regex for IP or hostname)
            if ! [[ "$host" =~ ^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$ || "$host" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo -e "${RED}Error: Invalid host format. Must be a valid hostname or IP address.${NC}"
                exit 1
            fi

            # Port validation
            if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
                echo -e "${RED}Error: Invalid port number. Must be between 1 and 65535.${NC}"
                exit 1
            fi

            is_ssl=false
            if [ "$ssl_str" == "ssl" ]; then
                is_ssl=true
            elif [ "$ssl_str" != "nossl" ]; then
                echo -e "${RED}Error: Invalid SSL/TLS option. Use 'ssl' or 'nossl'.${NC}"
                exit 1
            fi

        server_json_part=$(jq -n --arg host "$host" --argjson port "$port" --argjson ssl "$is_ssl" \
          '{host: $host, port: $port, is_ssl: $ssl}')
        
        if [ -z "$servers_json" ]; then
            servers_json="$server_json_part"
        else
            servers_json="$servers_json, $server_json_part"
        fi
    done

    echo -e "${GREEN}Updating $CONFIG_FILE with new stratum servers...${NC}"
    jq --argjson new_servers "[$servers_json]" '.stratum_server = $new_servers' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    echo -e "${GREEN}Config file updated.${NC}"
fi

echo "Changing directory to $AGENT_DIR"
cd "$AGENT_DIR" || exit

# Detect CPU architecture and create symlink
BIN_DIR="$AGENT_DIR/bin"
ARCH=$(uname -m)
EXE_NAME="${MINER}_mineragent.exe"
SYMLINK_PATH="$BIN_DIR/$EXE_NAME"

if [ ! -d "$BIN_DIR" ]; then
    echo -e "${RED}Error: bin directory not found at $BIN_DIR${NC}"
    exit 1
fi

# Grant execute permissions to files in bin directory
echo -e "${GREEN}Setting execute permissions for files in bin directory...${NC}"
chmod +x "$BIN_DIR"/* 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Execute permissions set successfully.${NC}"
else
    echo -e "${YELLOW}Warning: Some files in bin directory may not have execute permissions.${NC}"
fi

# Determine architecture-specific executable name
if [ "$ARCH" == "x86_64" ]; then
    ARCH_EXE="${MINER}_mineragent-x86_64.exe"
elif [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
    ARCH_EXE="${MINER}_mineragent-aarch64.exe"
else
    echo -e "${RED}Error: Unsupported CPU architecture: $ARCH${NC}"
    echo -e "${RED}Supported architectures: x86_64, aarch64/arm64${NC}"
    exit 1
fi

ARCH_EXE_PATH="$BIN_DIR/$ARCH_EXE"

# Check if architecture-specific executable exists
if [ ! -f "$ARCH_EXE_PATH" ]; then
    echo -e "${RED}Error: Executable not found: $ARCH_EXE_PATH${NC}"
    exit 1
fi

# Remove existing symlink if it exists
if [ -L "$SYMLINK_PATH" ] || [ -f "$SYMLINK_PATH" ]; then
    rm -f "$SYMLINK_PATH"
fi

# Create symlink
ln -s "$ARCH_EXE" "$SYMLINK_PATH"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Created symlink: $SYMLINK_PATH -> $ARCH_EXE${NC}"
else
    echo -e "${RED}Error: Failed to create symlink $SYMLINK_PATH${NC}"
    exit 1
fi

# Grant execute permissions to shell scripts
if [ -d "./shell" ]; then
    chmod +x ./shell/*.sh 2>/dev/null
fi

RESTART_SCRIPT=""
if [ -f "./shell/restart.sh" ]; then
    RESTART_SCRIPT="./shell/restart.sh"
elif [ -f "./shell/restart.h" ]; then # for ltc case
    RESTART_SCRIPT="./shell/restart.h"
fi

if [ -n "$RESTART_SCRIPT" ]; then
    echo -e "${GREEN}Starting ${MINER}_mineragent using $RESTART_SCRIPT...${NC}"
    bash "$RESTART_SCRIPT"
else
    echo -e "${RED}Error: Restart script not found for ${MINER}_mineragent in $AGENT_DIR/shell/${NC}"
    cd "$SCRIPT_DIR" || exit
    exit 1
fi

# Check if listener and worker processes are running
echo "Checking for ${MINER}_mineragent processes..."
if ! pgrep -f "${MINER}_mineragent_listener" > /dev/null; then
    echo -e "${RED}Error: ${MINER}_mineragent_listener process not found.${NC}"
    exit 1
fi

if ! pgrep -f "${MINER}_mineragent_worker_" > /dev/null; then
    echo -e "${RED}Error: ${MINER}_mineragent_worker_ process not found.${NC}"
    exit 1
fi

echo -e "${GREEN}Successfully found ${MINER}_mineragent processes.${NC}"

# Go back to the script's directory
cd "$SCRIPT_DIR" || exit

# Setup cron job for the specified miner
CHECK_ALIVE_SCRIPT="$AGENT_DIR/shell/check_alive.sh"
if [ -f "$CHECK_ALIVE_SCRIPT" ]; then
    CRON_JOB="*/1 * * * * $CHECK_ALIVE_SCRIPT >/dev/null 2>&1"
    # Add the cron job if it doesn't exist
    # Safely add cron job using a temporary file
    CRON_TMP_FILE=$(mktemp)
    # Export current crontab to temp file, or create an empty file if it doesn't exist
    sudo crontab -l -u root > "$CRON_TMP_FILE" 2>/dev/null

    # Check if the job already exists
    if ! grep -Fq "$CHECK_ALIVE_SCRIPT" "$CRON_TMP_FILE"; then
        # If not, append the new job to the temp file
        echo "$CRON_JOB" >> "$CRON_TMP_FILE"
        # Load the new crontab from the temp file
        sudo crontab -u root "$CRON_TMP_FILE"
        echo -e "${GREEN}Cron job for ${MINER}_mineragent has been set up (root).${NC}"
    else
        echo -e "${YELLOW}Cron job for ${MINER}_mineragent already exists.${NC}"
    fi
    # Clean up the temp file
    rm -f "$CRON_TMP_FILE"
else
    echo -e "${RED}Warning: check_alive.sh not found for $MINER. Cron job not set.${NC}"
fi

echo -e "${GREEN}Start for ${MINER}_mineragent is complete.${NC}"
