# MacAPIBridge Installation

This package contains the MacAPIBridge binary and configuration files needed to integrate with Claude Desktop.

## Installation Options

### Option 1: Automatic Installation

Run the following command in your terminal to automatically download and install MacAPIBridge:

```bash
curl -fsSL https://storage.googleapis.com/felafax-public/mcp-install/install.sh | bash
```

### Option 2: Manual Installation

1. Download the installation package:
   ```bash
   gsutil -m cp -r gs://felafax-public/mcp-install ~/Downloads/
   ```

2. Navigate to the downloaded directory:
   ```bash
   cd ~/Downloads/mcp-install
   ```

3. Run the installation script:
   ```bash
   bash install.sh
   ```

## What Gets Installed

- MacAPIBridge binary: `~/.mcp/bin/MacAPIBridge`
- Setup files: `~/.mcp/setup-permissions.swift` and `~/.mcp/CalendarAPIBridge.entitlements`
- Node.js modules:
  - Calendar module: `~/.mcp/node/calendars/`
  - Reminders module: `~/.mcp/node/reminders/`
- Claude Desktop configuration: `~/Library/Application Support/Claude/claude_desktop_config.json`

## Configuration

If you already have a Claude Desktop configuration file, the installer will:
1. Create a backup of your existing configuration
2. Check if you already have mcpServers configured
3. If mcpServers exists, provide you with the snippet to manually update your configuration
4. If mcpServers doesn't exist, automatically update your configuration

The mcpServers configuration snippet looks like this:
```json
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
```

## Troubleshooting

If you encounter any issues during installation:

1. Make sure you have the Google Cloud SDK installed if using the manual installation method.
2. Check that you have Swift installed on your system.
3. Ensure you have the necessary permissions to write to the installation directories.

## Uninstallation

To uninstall MacAPIBridge:

```bash
rm -rf ~/.mcp
rm ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Note: This will remove the Claude Desktop configuration file. If you've made other customizations to this file, you should back it up first. 