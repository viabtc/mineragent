#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the absolute path of the script's directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Check and install required dependencies
echo "Checking required dependencies..."
REQUIRED_PACKAGES=("jq" "unzip" "wget" "md5sum")
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

# Step 1: Download latest version to temporary directory
echo -e "${GREEN}Step 1: Downloading latest version...${NC}"
TEMP_DIR=$(mktemp -d)
TEMP_ZIP="$TEMP_DIR/viabtc_mineragent.zip"

if ! wget -q https://download.viabtc.top/viabtc_mineragent.zip -O "$TEMP_ZIP"; then
    echo -e "${RED}Error: Failed to download latest version.${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi
echo -e "${GREEN}Download completed.${NC}"

# Step 2: Compare MD5 if old zip exists
OLD_ZIP="$SCRIPT_DIR/viabtc_mineragent.zip"
if [ -f "$OLD_ZIP" ]; then
    echo -e "${GREEN}Step 2: Comparing MD5 checksums...${NC}"
    OLD_MD5=$(md5sum "$OLD_ZIP" | awk '{print $1}')
    NEW_MD5=$(md5sum "$TEMP_ZIP" | awk '{print $1}')
    
    if [ "$OLD_MD5" = "$NEW_MD5" ]; then
        echo -e "${GREEN}MD5 checksums match. No update needed.${NC}"
        rm -rf "$TEMP_DIR"
        exit 0
    else
        echo -e "${YELLOW}MD5 checksums differ. Update required.${NC}"
        echo -e "${YELLOW}Old MD5: $OLD_MD5${NC}"
        echo -e "${YELLOW}New MD5: $NEW_MD5${NC}"
    fi
else
    echo -e "${GREEN}Step 2: No existing zip file found. Proceeding with update...${NC}"
fi

# Step 3: Backup crontab and clear mineragent related cron jobs
echo -e "${GREEN}Step 3: Backing up crontab and clearing mineragent related cron jobs...${NC}"
CRON_BACKUP="$TEMP_DIR/crontab.backup.$(date +%Y%m%d_%H%M%S)"
if sudo crontab -l -u root > "$CRON_BACKUP" 2>/dev/null; then
    echo -e "${GREEN}Crontab backed up to: $CRON_BACKUP${NC}"
else
    echo -e "${YELLOW}No existing crontab found or failed to backup.${NC}"
fi

# Remove mineragent related cron jobs
CRON_TMP_FILE=$(mktemp)
sudo crontab -l -u root > "$CRON_TMP_FILE" 2>/dev/null
if [ -s "$CRON_TMP_FILE" ]; then
    # Remove lines containing mineragent check_alive.sh
    grep -v "mineragent.*check_alive.sh" "$CRON_TMP_FILE" > "${CRON_TMP_FILE}.new" || true
    if [ -s "${CRON_TMP_FILE}.new" ]; then
        sudo crontab -u root "${CRON_TMP_FILE}.new"
    else
        # If no jobs left, remove crontab
        sudo crontab -r -u root 2>/dev/null || true
    fi
    rm -f "${CRON_TMP_FILE}.new"
fi
rm -f "$CRON_TMP_FILE"
echo -e "${GREEN}Mineragent cron jobs cleared.${NC}"

# Step 4: Stop all mineragent processes
echo -e "${GREEN}Step 4: Stopping all mineragent processes...${NC}"
cd "$SCRIPT_DIR" || exit 1

# Find all mineragent directories
for mineragent_dir in */; do
    if [[ "$mineragent_dir" =~ ^([a-z]+)_mineragent/$ ]]; then
        coin_name="${BASH_REMATCH[1]}"
        echo -e "${GREEN}Stopping ${coin_name}_mineragent processes...${NC}"
        sudo killall -s SIGQUIT "${coin_name}_mineragent.exe" > /dev/null 2>&1
        # Also try to kill listener and worker processes
        sudo killall -s SIGQUIT "${coin_name}_mineragent_listener" > /dev/null 2>&1
        sudo killall -s SIGQUIT "${coin_name}_mineragent_worker_" > /dev/null 2>&1
        sleep 1
    fi
done
echo -e "${GREEN}All mineragent processes stopped.${NC}"

# Step 5: Backup bin directories
echo -e "${GREEN}Step 5: Backing up bin directories...${NC}"
for mineragent_dir in */; do
    if [[ "$mineragent_dir" =~ ^([a-z]+)_mineragent/$ ]]; then
        coin_name="${BASH_REMATCH[1]}"
        agent_path="$SCRIPT_DIR/${coin_name}_mineragent"
        bin_path="$agent_path/bin"
        bin_old_path="$agent_path/bin_old"
        
        if [ -d "$bin_path" ]; then
            # Remove old backup if exists
            if [ -d "$bin_old_path" ]; then
                rm -rf "$bin_old_path"
            fi
            # Create backup
            cp -rf "$bin_path" "$bin_old_path"
            echo -e "${GREEN}Backed up $bin_path to $bin_old_path${NC}"
        fi
    fi
done

# Step 6: Extract and update files
echo -e "${GREEN}Step 6: Extracting and updating files...${NC}"
cd "$TEMP_DIR" || exit 1

if ! unzip -q viabtc_mineragent.zip; then
    echo -e "${RED}Error: Failed to extract viabtc_mineragent.zip${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

NEW_VERSION_DIR="$TEMP_DIR/mineragent-master/linux"
if [ ! -d "$NEW_VERSION_DIR" ]; then
    echo -e "${RED}Error: mineragent-master/linux directory not found in extracted files.${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

cd "$NEW_VERSION_DIR" || exit 1

# Copy bin directories for existing mineragents
for mineragent_dir in */; do
    if [[ "$mineragent_dir" =~ ^([a-z]+)_mineragent/$ ]]; then
        coin_name="${BASH_REMATCH[1]}"
        new_bin_path="$NEW_VERSION_DIR/${coin_name}_mineragent/bin"
        old_agent_path="$SCRIPT_DIR/${coin_name}_mineragent"
        old_bin_path="$old_agent_path/bin"
        
        if [ -d "$new_bin_path" ] && [ -d "$old_agent_path" ]; then
            # Remove old bin directory
            if [ -d "$old_bin_path" ]; then
                rm -rf "$old_bin_path"
            fi
            # Copy new bin directory
            cp -rf "$new_bin_path" "$old_bin_path"
            echo -e "${GREEN}Updated bin directory for ${coin_name}_mineragent${NC}"
        fi
    fi
done

# Copy new mineragent folders if they don't exist
for mineragent_dir in */; do
    if [[ "$mineragent_dir" =~ ^([a-z]+)_mineragent/$ ]]; then
        coin_name="${BASH_REMATCH[1]}"
        new_agent_path="$NEW_VERSION_DIR/${coin_name}_mineragent"
        old_agent_path="$SCRIPT_DIR/${coin_name}_mineragent"
        
        if [ ! -d "$old_agent_path" ]; then
            # Copy entire new mineragent folder
            cp -rf "$new_agent_path" "$SCRIPT_DIR/"
            echo -e "${GREEN}Copied new mineragent folder: ${coin_name}_mineragent${NC}"
        fi
    fi
done

# Copy start.sh script
if [ -f "$NEW_VERSION_DIR/start.sh" ]; then
    cp -f "$NEW_VERSION_DIR/start.sh" "$SCRIPT_DIR/start.sh"
    chmod +x "$SCRIPT_DIR/start.sh"
    echo -e "${GREEN}Updated start.sh script${NC}"
fi

# Step 7: Copy new zip file to script directory
echo -e "${GREEN}Step 7: Copying new zip file to script directory...${NC}"
cp -f "$TEMP_ZIP" "$OLD_ZIP"
echo -e "${GREEN}New version zip file saved to: $OLD_ZIP${NC}"

# Step 8: Restore crontab from backup
echo -e "${GREEN}Step 8: Restoring crontab from backup...${NC}"
if [ -f "$CRON_BACKUP" ] && [ -s "$CRON_BACKUP" ]; then
    if sudo crontab -u root "$CRON_BACKUP"; then
        echo -e "${GREEN}Crontab restored successfully from: $CRON_BACKUP${NC}"
    else
        echo -e "${RED}Warning: Failed to restore crontab from backup.${NC}"
        # Move backup file to script directory for manual recovery
        BACKUP_FILENAME=$(basename "$CRON_BACKUP")
        mv "$CRON_BACKUP" "$SCRIPT_DIR/$BACKUP_FILENAME"
        echo -e "${YELLOW}Backup file moved to: $SCRIPT_DIR/$BACKUP_FILENAME${NC}"
    fi
else
    echo -e "${YELLOW}No crontab backup found or backup file is empty. Skipping restore.${NC}"
fi

# Cleanup
rm -rf "$TEMP_DIR"
echo -e "${GREEN}Update completed successfully!${NC}"
echo -e "${YELLOW}Note: Please restart mineragents manually using start.sh script.${NC}"

