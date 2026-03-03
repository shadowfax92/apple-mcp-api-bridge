<div align="center">

# 🍎 Apple MCP API Bridge

**Native Swift bridge for macOS Calendar.**

*Access Apple Calendar from any language via HTTP.*

</div>

Your MCP server needs to read and write macOS Calendar events, but EventKit only speaks Swift. This bridge runs a local HTTP server that exposes Calendar operations as a REST API. Any language, any tool, any MCP server — just make HTTP requests to localhost.

- 📅 **Full CRUD** — list, create, update, and delete calendars and events
- 🔌 **REST API** — standard HTTP endpoints, works with any HTTP client
- 🎨 **Color support** — hex color codes for calendar creation
- 📆 **Flexible dates** — accepts multiple ISO8601 formats
- 🔒 **Permission-aware** — respects macOS calendar access and read-only calendars
- ⚡ **One-line install** — curl script handles build and setup

---

## Tech Stack

| | |
|---|---|
| **Language** | Swift 5.5+ |
| **Framework** | Vapor 4.0 (HTTP server) |
| **Apple API** | EventKit (calendar access) |
| **Platform** | macOS 12.0+ |

## Install

```sh
curl -fsSL https://storage.googleapis.com/felafax-public/mcp-install/install.sh | bash
```

Or build manually:

```sh
swift build -c release
cp .build/release/MacAPIBridge /usr/local/bin/
```

## Quick Start

```sh
# 1. Start the bridge
MacAPIBridge
# → Server running on http://localhost:8080

# 2. List your calendars
curl http://localhost:8080/calendars

# 3. Create an event
curl -X POST http://localhost:8080/calendars/{id}/events \
  -H "Content-Type: application/json" \
  -d '{"title":"Meeting","startDate":"2025-03-09T10:00:00Z","endDate":"2025-03-09T11:00:00Z"}'
```

## Config

| Variable | Description | Default |
|----------|-------------|---------|
| `MAC_API_BRIDGE_PORT` | Server port | `8080` |

## API

### Calendars

```
GET    /calendars          # List all calendars
GET    /calendars/:id      # Get calendar details
POST   /calendars          # Create calendar  {"title", "color"}
DELETE /calendars/:id      # Delete calendar
```

### Events

```
GET    /calendars/:calId/events              # List events (30d past → 1y future)
GET    /calendars/:calId/events/:eventId     # Get event details
POST   /calendars/:calId/events              # Create event
PUT    /calendars/:calId/events/:eventId     # Update event
DELETE /calendars/:calId/events/:eventId     # Delete event
```

### Event Fields

```json
{
  "title": "Team standup",
  "startDate": "2025-03-09T10:00:00Z",
  "endDate": "2025-03-09T10:30:00Z",
  "location": "Room 4",
  "notes": "Weekly sync",
  "url": "https://meet.google.com/abc",
  "isAllDay": false
}
```

## Claude Desktop Integration

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "calendar": {
      "command": "node",
      "args": ["$HOME/.mcp/node/calendars/index.js"]
    }
  }
}
```

## How It Works

A Vapor HTTP server runs locally and uses EventKit to talk to macOS Calendar. Each API request maps to an EventKit operation — no external databases, no sync, no state. The bridge reads from and writes to the same calendars you see in Apple Calendar.app.

Calendar access requires a one-time macOS permission grant. The bridge checks authorization at startup and warns if access is missing.

---

> Personal tool built for MCP calendar integration. Feel free to fork and adapt.
