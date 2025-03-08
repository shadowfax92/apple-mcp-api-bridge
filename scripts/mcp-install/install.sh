#!/bin/bash

# MacAPIBridge Installation Script

set -e

# Configuration
INSTALL_DIR="$HOME/.mcp"
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"

echo "=== MacAPIBridge Installer ==="
echo "This script will install MacAPIBridge and configure Claude Desktop."

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Copy files to installation directory
echo "Installing MacAPIBridge..."
cp -r ./bin "$INSTALL_DIR/"
cp -r ./node "$INSTALL_DIR/"
cp ./setup-permissions.swift "$INSTALL_DIR/"
cp ./CalendarAPIBridge.entitlements "$INSTALL_DIR/"

# Make binary executable
chmod +x "$INSTALL_DIR/bin/MacAPIBridge"

# Create Claude config directory if it doesn't exist
mkdir -p "$CLAUDE_CONFIG_DIR"

# Check if config file already exists
if [ -f "$CLAUDE_CONFIG_FILE" ]; then
    echo "Claude desktop config file already exists. Creating backup..."
    cp "$CLAUDE_CONFIG_FILE" "$CLAUDE_CONFIG_FILE.backup"
    
    # Check if mcpServers already exists in the config
    if grep -q "mcpServers" "$CLAUDE_CONFIG_FILE"; then
        echo "mcpServers configuration already exists in Claude desktop config."
        echo "To update it manually, add the following to your config file:"
        echo ""
        cat "./mcpServers_snippet.json"
        echo ""
        echo "Or replace your entire config with:"
        cat "./claude_desktop_config.json"
    else
        # Update existing config file with MCP servers
        echo "Updating Claude desktop config..."
        cp "./claude_desktop_config.json" "$CLAUDE_CONFIG_FILE"
    fi
else
    echo "Creating Claude desktop config file..."
    cp "./claude_desktop_config.json" "$CLAUDE_CONFIG_FILE"
fi

# Set up permissions
echo "Setting up permissions..."
swift "$INSTALL_DIR/setup-permissions.swift"

echo "Installation complete!"
echo "MacAPIBridge has been installed to $INSTALL_DIR/bin/MacAPIBridge"
echo "Calendar and Reminder modules have been installed to $INSTALL_DIR/node/"
echo "Claude desktop configuration has been updated at $CLAUDE_CONFIG_FILE"

# Run the MacAPIBridge binary
echo ""
echo "Starting MacAPIBridge..."
cd "$INSTALL_DIR/bin"
./MacAPIBridge &
echo "MacAPIBridge is now running in the background."
echo "You can access it at http://localhost:8080"
