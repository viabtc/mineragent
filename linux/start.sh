#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Get the absolute path of the script's directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

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
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}jq could not be found. Please install it first.${NC}"
        echo -e "${RED}On Ubuntu: sudo apt-get install jq${NC}"
        exit 1
    else
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
fi

echo "Changing directory to $AGENT_DIR"
cd "$AGENT_DIR" || exit

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

# Go back to the script's directory
cd "$SCRIPT_DIR" || exit

# Setup cron job for the specified miner
CHECK_ALIVE_SCRIPT="$AGENT_DIR/shell/check_alive.sh"
if [ -f "$CHECK_ALIVE_SCRIPT" ]; then
    CRON_JOB="*/1 * * * * $CHECK_ALIVE_SCRIPT >/dev/null 2>&1"
    # Add the cron job if it doesn't exist
    (crontab -l 2>/dev/null | grep -Fq "$CHECK_ALIVE_SCRIPT") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo -e "${GREEN}Cron job for ${MINER}_mineragent has been set up.${NC}"
else
    echo -e "${RED}Warning: check_alive.sh not found for $MINER. Cron job not set.${NC}"
fi

echo -e "${GREEN}Start for ${MINER}_mineragent is complete.${NC}"