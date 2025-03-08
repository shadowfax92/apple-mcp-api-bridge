#!/bin/bash

# Script to upload MacAPIBridge binary and installation files to Google Cloud Storage
# This script packages everything into a single zip file and creates a simple installer

set -e

# Configuration
BUCKET_NAME="felafax-public"
BINARY_PATH="/Users/shadowfax/code/hackathon/mcp/swift-apple-api/.build/arm64-apple-macosx/release/MacAPIBridge"
CALENDARS_DIST="/Users/shadowfax/code/hackathon/mcp/mcp-apple-calendars/dist"
REMINDERS_DIST="/Users/shadowfax/code/hackathon/mcp/mcp-apple-reminders/dist"
TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="$TEMP_DIR/mcp-package"
ZIP_FILE="$TEMP_DIR/mcp-package.zip"
INSTALLER_SCRIPT="$TEMP_DIR/install.sh"

# Function to check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    if [ ! -f "$BINARY_PATH" ]; then
        echo "Error: Binary not found at $BINARY_PATH"
        echo "Please build the project first with: swift build -c release"
        exit 1
    fi

    if [ ! -d "$CALENDARS_DIST" ]; then
        echo "Error: Calendars dist directory not found at $CALENDARS_DIST"
        exit 1
    fi

    if [ ! -d "$REMINDERS_DIST" ]; then
        echo "Error: Reminders dist directory not found at $REMINDERS_DIST"
        exit 1
    fi
}

# Function to create the package directory structure
create_package() {
    echo "Creating package directory structure..."
    
    mkdir -p "$PACKAGE_DIR/bin"
    mkdir -p "$PACKAGE_DIR/node/calendars"
    mkdir -p "$PACKAGE_DIR/node/reminders"

    # Copy binary
    echo "Copying binary to package..."
    cp "$BINARY_PATH" "$PACKAGE_DIR/bin/"

    # Copy configuration files and scripts
    echo "Copying configuration files and scripts..."
    cp "/Users/shadowfax/code/hackathon/mcp/swift-apple-api/CalendarAPIBridge.entitlements" "$PACKAGE_DIR/"
    cp "/Users/shadowfax/code/hackathon/mcp/swift-apple-api/setup-permissions.swift" "$PACKAGE_DIR/"

    # Copy node modules
    echo "Copying calendars and reminders dist files..."
    cp -r "$CALENDARS_DIST"/* "$PACKAGE_DIR/node/calendars/"
    cp -r "$REMINDERS_DIST"/* "$PACKAGE_DIR/node/reminders/"

    # Create sample config file
    cat > "$PACKAGE_DIR/claude_desktop_config.json" << EOL
{
  "globalShortcut": "",
  "mcpServers": {
    "reminders": {
      "command": "node",
      "args": [
        "$HOME/.mcp/node/reminders/index.js"
      ]
    },
    "calendar": {
      "command": "node",
      "args": [
        "$HOME/.mcp/node/calendars/index.js"
      ]
    }
  }
}
EOL

    # Create a sample mcpServers JSON snippet for users with existing config
    cat > "$PACKAGE_DIR/mcpServers_snippet.json" << EOL
"mcpServers": {
  "reminders": {
    "command": "node",
    "args": [
      "$HOME/.mcp/node/reminders/index.js"
    ]
  },
  "calendar": {
    "command": "node",
    "args": [
      "$HOME/.mcp/node/calendars/index.js"
    ]
  }
}
EOL

    # Create the installation script inside the package
    cat > "$PACKAGE_DIR/install.sh" << EOL
#!/bin/bash

# MacAPIBridge Installation Script

set -e

# Configuration
INSTALL_DIR="\$HOME/.mcp"
CLAUDE_CONFIG_DIR="\$HOME/Library/Application Support/Claude"
CLAUDE_CONFIG_FILE="\$CLAUDE_CONFIG_DIR/claude_desktop_config.json"

echo "=== MacAPIBridge Installer ==="
echo "This script will install MacAPIBridge and configure Claude Desktop."

# Create installation directory
mkdir -p "\$INSTALL_DIR/bin"
mkdir -p "\$INSTALL_DIR/node/calendars"
mkdir -p "\$INSTALL_DIR/node/reminders"

# Copy files to installation directory
echo "Installing MacAPIBridge..."
cp ./bin/MacAPIBridge "\$INSTALL_DIR/bin/"
chmod +x "\$INSTALL_DIR/bin/MacAPIBridge"

cp ./setup-permissions.swift "\$INSTALL_DIR/"
cp ./CalendarAPIBridge.entitlements "\$INSTALL_DIR/"

echo "Installing node modules..."
cp -r ./node/calendars/* "\$INSTALL_DIR/node/calendars/"
cp -r ./node/reminders/* "\$INSTALL_DIR/node/reminders/"

# Create Claude config directory if it doesn't exist
mkdir -p "\$CLAUDE_CONFIG_DIR"

# Check if config file already exists
if [ -f "\$CLAUDE_CONFIG_FILE" ]; then
    echo "Claude desktop config file already exists. Creating backup..."
    cp "\$CLAUDE_CONFIG_FILE" "\$CLAUDE_CONFIG_FILE.backup"
    
    # Check if mcpServers already exists in the config
    if grep -q "mcpServers" "\$CLAUDE_CONFIG_FILE"; then
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
        cp "./claude_desktop_config.json" "\$CLAUDE_CONFIG_FILE"
    fi
else
    echo "Creating Claude desktop config file..."
    cp "./claude_desktop_config.json" "\$CLAUDE_CONFIG_FILE"
fi

# Set up permissions
echo "Setting up permissions..."
swift "\$INSTALL_DIR/setup-permissions.swift"

echo "Installation complete!"
echo "MacAPIBridge has been installed to \$INSTALL_DIR/bin/MacAPIBridge"
echo "Calendar and Reminder modules have been installed to \$INSTALL_DIR/node/"
echo "Claude desktop configuration has been updated at \$CLAUDE_CONFIG_FILE"

# Run the MacAPIBridge binary
echo ""
echo "Starting MacAPIBridge..."
cd "\$INSTALL_DIR/bin"
./MacAPIBridge &
echo "MacAPIBridge is now running in the background."
echo "You can access it at http://localhost:8080"
EOL

    # Make the installation script executable
    chmod +x "$PACKAGE_DIR/install.sh"
}

# Function to create the zip archive
create_zip() {
    echo "Creating zip archive..."
    
    cd "$PACKAGE_DIR"
    zip -r "$ZIP_FILE" ./*
    
    echo "Zip archive created at $ZIP_FILE"
}

# Function to create the standalone installer script
create_installer() {
    echo "Creating standalone installer script..."
    
    cat > "$INSTALLER_SCRIPT" << EOL
#!/bin/bash

# MacAPIBridge One-Line Installer
# This script downloads and installs MacAPIBridge from Google Cloud Storage

set -e

echo "=== MacAPIBridge One-Line Installer ==="
echo "This script will download and install MacAPIBridge and configure Claude Desktop."

# Create temporary directory
TEMP_DIR=\$(mktemp -d)
ZIP_FILE="\$TEMP_DIR/mcp-package.zip"

# Download the package
echo "Downloading MacAPIBridge package..."
curl -fsSL "https://storage.googleapis.com/felafax-public/mcp-package.zip" -o "\$ZIP_FILE"

# Create a directory to extract the package
mkdir -p "\$TEMP_DIR/extract"
cd "\$TEMP_DIR/extract"

# Extract the package
echo "Extracting package..."
unzip -q "\$ZIP_FILE"

# Run the installer
echo "Running installer..."
bash ./install.sh

# Clean up
echo "Cleaning up..."
rm -rf "\$TEMP_DIR"

echo "MacAPIBridge installation completed successfully!"
# Note: The MacAPIBridge process is running in the background
echo "MacAPIBridge is running at http://localhost:8080"
EOL

    chmod +x "$INSTALLER_SCRIPT"
    
    echo "Installer script created at $INSTALLER_SCRIPT"
}

# Function to upload files to Google Cloud Storage
upload_to_gcs() {
    echo "Uploading files to Google Cloud Storage..."
    
    echo "Uploading zip package..."
    gsutil cp "$ZIP_FILE" "gs://$BUCKET_NAME/mcp-package.zip"
    
    echo "Uploading installer script..."
    gsutil cp "$INSTALLER_SCRIPT" "gs://$BUCKET_NAME/install.sh"
    
    echo "Upload complete!"
    echo "Zip package available at: gs://$BUCKET_NAME/mcp-package.zip"
    echo "Installer script available at: gs://$BUCKET_NAME/install.sh"
    echo ""
    echo "Users can install with: curl -fsSL https://storage.googleapis.com/felafax-public/install.sh | bash"
}

# Function to clean up temporary files
cleanup() {
    echo "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

# Main function
main() {
    echo "Starting MacAPIBridge packaging and upload process..."
    
    check_prerequisites
    create_package
    create_zip
    create_installer
    upload_to_gcs
    cleanup
    
    echo "Process completed successfully!"
}

# Run the main function
main 