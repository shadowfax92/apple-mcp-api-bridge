# MacAPIBridge

A Swift package that provides a bridge between macOS APIs and HTTP clients.

## Features

- RESTful API for macOS Calendar functionality
- Configurable port via environment variables

## Configuration

The server port can be configured using the `MAC_API_BRIDGE_PORT` environment variable:

```bash
# Run on port 3000
MAC_API_BRIDGE_PORT=3000 swift run MacAPIBridge
```

If no port is specified, the server will run on the default port 8080.

## Building and Running

```bash
# Build the package
swift build

# Run the server
swift run MacAPIBridge
```

## Requirements

- macOS 12.0 or later
- Swift 5.5 or later

## ⚠️ Important: Date Format Requirements

When working with dates in API requests (creating/updating events), you **must** use one of these supported date formats:

1. **ISO8601 with UTC timezone (Z) - RECOMMENDED**:
   ```javascript
   {
     "startDate": "2025-03-09T10:00:00.000Z",
     "endDate": "2025-03-09T11:00:00.000Z"
   }
   ```

2. **ISO8601 without milliseconds**:
   ```javascript
   {
     "startDate": "2025-03-09T10:00:00",
     "endDate": "2025-03-09T11:00:00"
   }
   ```

3. **ISO8601 with space instead of T**:
   ```javascript
   {
     "startDate": "2025-03-09 10:00:00",
     "endDate": "2025-03-09 11:00:00"
   }
   ```

Using any other date format will result in a 400 Bad Request error.

## Features

- List, view, create, and delete calendars
- List, view, create, update, and delete events
- RESTful API with JSON request/response format
- Runs as a background service on macOS

## Installation

### Option 1: One-Line Installation (Recommended)

You can install MacAPIBridge with a single command:

```bash
curl -fsSL https://storage.googleapis.com/felafax-public/mcp-install/install.sh | bash
```

This will:
1. Download and install the MacAPIBridge binary to `~/.mcp/bin/MacAPIBridge`
2. Set up the necessary permissions
3. Configure Claude Desktop to use MacAPIBridge

### Option 2: Manual Installation

1. Clone this repository
2. Build the application:
   ```
   swift build -c release
   ```
3. Set up calendar permissions:
   ```
   ./setup-permissions.swift
   ```
   This will prompt you to grant calendar access permissions.

4. Copy the built executable to a location of your choice:
   ```
   cp .build/release/MacAPIBridge /usr/local/bin/
   ```

### Claude Desktop Integration

MacAPIBridge can be integrated with Claude Desktop by updating the configuration file at `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "globalShortcut": "",
  "mcpServers": {
    "reminders": {
      "command": "node",
      "args": [
        "/Users/shadowfax/code/hackathon/mcp/mcp-apple-reminders/dist/index.js"
      ]
    },
    "calendar": {
      "command": "node",
      "args": [
        "/Users/shadowfax/code/hackathon/mcp/mcp-apple-calendars/dist/index.js"
      ]
    }
  }
}
```

The one-line installer will automatically set up this configuration.

## Usage

### Setting Up Calendar Permissions

Before running the application, you need to grant it access to your macOS Calendar. You can do this by running the setup script:

```
./setup-permissions.swift
```

If you don't see the permission prompt, or if you previously denied access, you can grant access in System Preferences:

1. Open System Preferences
2. Go to Security & Privacy > Privacy > Calendars
3. Check the box next to MacAPIBridge to grant access

### Starting the Server

```
MacAPIBridge
```

The server will start on port 8080 by default. To use a custom port:

```
MAC_API_BRIDGE_PORT=3000 MacAPIBridge
```

### Running in the Background

To run the application in the background:

```
nohup MacAPIBridge > /tmp/mac-api-bridge.log 2>&1 &
```

### API Endpoints

#### Calendars

- `GET /calendars` - List all calendars
- `GET /calendars/:id` - Get calendar details
- `POST /calendars` - Create a new calendar
- `DELETE /calendars/:id` - Delete a calendar

#### Events

- `GET /calendars/:calendarId/events` - List events in a calendar
- `GET /calendars/:calendarId/events/:eventId` - Get event details
- `POST /calendars/:calendarId/events` - Create a new event
- `PUT /calendars/:calendarId/events/:eventId` - Update an event
- `DELETE /calendars/:calendarId/events/:eventId` - Delete an event

### Example API Requests

#### List Calendars

```
curl http://localhost:8080/calendars
```

#### Create Calendar

```
curl -X POST http://localhost:8080/calendars \
  -H "Content-Type: application/json" \
  -d '{"title": "My New Calendar", "color": "#FF0000"}'
```

#### List Events

```
curl http://localhost:8080/calendars/{calendarId}/events
```

Replace `{calendarId}` with an actual calendar ID from the list calendars response.

#### Create Event

```
curl -X POST http://localhost:8080/calendars/{calendarId}/events \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Meeting",
    "startDate": "2023-06-01T10:00:00Z",
    "endDate": "2023-06-01T11:00:00Z",
    "location": "Conference Room",
    "notes": "Discuss project status"
  }'
```

Replace `{calendarId}` with an actual calendar ID.

## Troubleshooting

### Common Issues

1. **Calendar Access Denied**: Make sure to grant Calendar access to the application in System Preferences > Security & Privacy > Privacy > Calendars.

2. **Port Already in Use**: If port 8080 is already in use, you can specify a different port using the `MAC_API_BRIDGE_PORT` environment variable.

3. **Application Crashes**: Check the error logs for more information. The application may crash if it cannot access the Calendar or if there are issues with the HTTP server.

4. **Permission Issues**: If you're having trouble with calendar permissions, try running the setup script:
   ```
   ./setup-permissions.swift
   ```

## Development

See the [Development Guide](docs/dev.md) for information on how to set up your development environment and contribute to the project.

## Installation Scripts

The `scripts` directory contains tools for deploying and installing MacAPIBridge:

- `upload_to_gcp.sh`: Uploads the binary and installation files to Google Cloud Storage
- `install_from_gcp.sh`: Downloads and installs MacAPIBridge from Google Cloud Storage
- `mcp-install/install.sh`: Standalone installation script for one-line installation

For more information, see the [Scripts README](scripts/README.md).

## License

MIT
