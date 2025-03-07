# Development Guide

This guide provides instructions for setting up your development environment and working on the Calendar API Bridge project.

## Prerequisites

- macOS 12.0 or later
- Swift 5.5 or later
- Xcode 13.0 or later
- [Swift Package Manager](https://swift.org/package-manager/)

## Setting Up the Development Environment

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/calendar-api-bridge.git
   cd calendar-api-bridge
   ```

2. Open the project in Xcode:
   ```
   open Package.swift
   ```
   This will open the project in Xcode.

3. Build the project:
   ```
   swift build
   ```

## Project Structure

- `Sources/CalendarAPIBridge/` - Main application code
  - `main.swift` - Application entry point
  - `Models/` - Data models
  - `Controllers/` - API controllers
- `Tests/` - Test code

## Running the Application

### From Xcode

1. Select the "CalendarAPIBridge" scheme
2. Click the "Run" button or press Cmd+R

### From Command Line

```
swift run
```

The server will start on port 8080 by default.

## Testing

### Running Tests

```
swift test
```

## Debugging

When running the application, you may need to grant Calendar access permissions. The application will prompt for this when it starts.

### Common Issues

1. **Calendar Access Denied**: Make sure to grant Calendar access to the application in System Preferences > Security & Privacy > Privacy > Calendars.

2. **Port Already in Use**: If port 8080 is already in use, you can modify the port in the code or terminate the other application using that port.

3. **NSColor Issues**: If you encounter errors related to NSColor, make sure to import AppKit in the file where NSColor is used.

4. **Content Protocol Conformance**: Models that are returned from API endpoints must conform to Vapor's `Content` protocol.

5. **Async Context Warnings**: When using Vapor in an async context, use the async versions of methods:
   - Use `Application.make(_:)` instead of `Application.init(_:)`
   - Use `app.execute()` instead of `app.run()`
   - Avoid using `app.shutdown()` in async contexts

## API Testing

You can test the API using tools like [curl](https://curl.se/) or [Postman](https://www.postman.com/).

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

## Building for Release

```
swift build -c release
```

The built executable will be located at `.build/release/CalendarAPIBridge`.

## Running as a Background Service

To run the application as a background service, you can create a launchd plist file:

1. Create a file at `~/Library/LaunchAgents/com.yourusername.calendar-api-bridge.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.yourusername.calendar-api-bridge</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/CalendarAPIBridge</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/calendar-api-bridge.err</string>
    <key>StandardOutPath</key>
    <string>/tmp/calendar-api-bridge.out</string>
</dict>
</plist>
```

2. Load the service:

```
launchctl load ~/Library/LaunchAgents/com.yourusername.calendar-api-bridge.plist
```

3. To unload the service:

```
launchctl unload ~/Library/LaunchAgents/com.yourusername.calendar-api-bridge.plist
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Submit a pull request 