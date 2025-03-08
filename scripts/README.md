# MacAPIBridge Installation Scripts

This directory contains scripts for uploading and installing the MacAPIBridge binary and configuration files.

## Scripts Overview

### `upload_to_gcp.sh`

This script uploads the MacAPIBridge binary and installation files to the Google Cloud Storage bucket `felafax-public`. It performs the following actions:

1. Checks if the binary exists at the expected location
2. Checks if the calendar and reminders dist directories exist
3. Creates an installation directory structure
4. Copies the binary and configuration files to the installation directory
5. Copies the calendar and reminders node modules to the installation directory
6. Creates a sample Claude Desktop configuration file and a configuration snippet
7. Creates an installation script
8. Uploads everything to Google Cloud Storage

Usage:
```bash
./upload_to_gcp.sh
```

### `install_from_gcp.sh`

This script downloads and installs the MacAPIBridge binary and configuration files from Google Cloud Storage. It's intended to be run locally on your machine.

Usage:
```bash
./install_from_gcp.sh
```

### `mcp-install/install.sh`

This is a standalone installation script that can be downloaded and executed with curl. It's designed to be hosted on Google Cloud Storage and used as follows:

```bash
curl -fsSL https://storage.googleapis.com/felafax-public/mcp-install/install.sh | bash
```

## Installation Directory Structure

The installation creates the following directory structure:

```
~/.mcp/
├── bin/
│   └── MacAPIBridge
├── node/
│   ├── calendars/
│   │   ├── index.js
│   │   └── calendars.js
│   └── reminders/
│       ├── index.js
│       └── reminders.js
├── setup-permissions.swift
└── CalendarAPIBridge.entitlements

~/Library/Application Support/Claude/
└── claude_desktop_config.json
```

## Prerequisites

- Google Cloud SDK (for upload and manual installation)
- Swift (for running the permissions setup)
- curl (for the one-line installer)

## Building the Binary

Before uploading, make sure to build the MacAPIBridge binary:

```bash
cd /Users/shadowfax/code/hackathon/mcp/swift-apple-api
swift build -c release
``` 