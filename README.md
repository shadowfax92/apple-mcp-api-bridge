# Calendar API Bridge

A Swift application that exposes macOS Calendar APIs through a local HTTP server. This allows Node.js applications and other services to interact with the macOS Calendar without needing to implement Swift code directly.

## Features

- List, view, create, and delete calendars
- List, view, create, update, and delete events
- RESTful API with JSON request/response format
- Runs as a background service on macOS

## Requirements

- macOS 12.0 or later
- Swift 5.5 or later
- Xcode 13.0 or later (for development)

## Installation

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
   cp .build/release/CalendarAPIBridge /usr/local/bin/
   ```

## Usage

### Setting Up Calendar Permissions

Before running the application, you need to grant it access to your macOS Calendar. You can do this by running the setup script:

```
./setup-permissions.swift
```

If you don't see the permission prompt, or if you previously denied access, you can grant access in System Preferences:

1. Open System Preferences
2. Go to Security & Privacy > Privacy > Calendars
3. Check the box next to CalendarAPIBridge to grant access

### Starting the Server

```
CalendarAPIBridge
```

The server will start on port 8080 by default.

### Running in the Background

To run the application in the background:

```
nohup CalendarAPIBridge > /tmp/calendar-api-bridge.log 2>&1 &
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

2. **Port Already in Use**: If port 8080 is already in use, you can modify the port in the code or terminate the other application using that port.

3. **Application Crashes**: Check the error logs for more information. The application may crash if it cannot access the Calendar or if there are issues with the HTTP server.

4. **Permission Issues**: If you're having trouble with calendar permissions, try running the setup script:
   ```
   ./setup-permissions.swift
   ```

## Development

See the [Development Guide](docs/dev.md) for information on how to set up your development environment and contribute to the project.

## License

MIT 