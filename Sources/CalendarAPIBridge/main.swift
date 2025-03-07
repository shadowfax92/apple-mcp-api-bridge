import Vapor
import EventKit
import Foundation

// Configure and start the application
struct CalendarAPIBridgeApp {
    static func configure(_ app: Application) throws {
        print("Configuring application...")
        
        // Configure routes
        print("Configuring routes...")
        try configureRoutes(app)
        
        // Add lifecycle handler
        app.lifecycle.use(CalendarAccessHandler())
    }
    
    // Configure all routes
    static func configureRoutes(_ app: Application) throws {
        // Register controllers
        try registerCalendarController(app)
        try registerEventController(app)
        
        // Add a root route for health check
        app.get { req -> String in
            return "CalendarAPIBridge is running! Access the API at /calendars"
        }
    }
    
    // Register calendar-related routes
    static func registerCalendarController(_ app: Application) throws {
        let calendarController = CalendarController()
        
        let calendarsGroup = app.grouped("calendars")
        
        // GET /calendars - List all calendars
        calendarsGroup.get { req in
            try await calendarController.listCalendars(req)
        }
        
        // GET /calendars/:calendarId - Get calendar details
        calendarsGroup.get(":calendarId") { req in
            try await calendarController.getCalendar(req)
        }
        
        // POST /calendars - Create a new calendar
        calendarsGroup.post { req in
            try await calendarController.createCalendar(req)
        }
        
        // DELETE /calendars/:calendarId - Delete a calendar
        calendarsGroup.delete(":calendarId") { req in
            try await calendarController.deleteCalendar(req)
        }
    }
    
    // Register event-related routes
    static func registerEventController(_ app: Application) throws {
        let eventController = EventController()
        
        let eventsGroup = app.grouped("calendars", ":calendarId", "events")
        
        // GET /calendars/:calendarId/events - List events in a calendar
        eventsGroup.get { req in
            try await eventController.listEvents(req)
        }
        
        // GET /calendars/:calendarId/events/:eventId - Get event details
        eventsGroup.get(":eventId") { req in
            try await eventController.getEvent(req)
        }
        
        // POST /calendars/:calendarId/events - Create a new event
        eventsGroup.post { req in
            try await eventController.createEvent(req)
        }
        
        // PUT /calendars/:calendarId/events/:eventId - Update an event
        eventsGroup.put(":eventId") { req in
            try await eventController.updateEvent(req)
        }
        
        // DELETE /calendars/:calendarId/events/:eventId - Delete an event
        eventsGroup.delete(":eventId") { req in
            try await eventController.deleteEvent(req)
        }
    }
}

// Calendar access handler
final class CalendarAccessHandler: LifecycleHandler {
    func willBoot(_ application: Application) throws {
        print("Checking calendar access before server starts...")
        
        // Check calendar authorization status
        let status = EKEventStore.authorizationStatus(for: .event)
        print("Current authorization status: \(status.rawValue)")
        
        if status != .authorized {
            print("⚠️ WARNING: Calendar access is not granted!")
            print("⚠️ Calendar operations will fail until access is granted.")
            print("⚠️ To grant access, go to System Preferences > Security & Privacy > Privacy > Calendars")
            print("⚠️ and check the box next to CalendarAPIBridge.")
        } else {
            print("✅ Calendar access is already granted.")
        }
    }
    
    func shutdown(_ application: Application) {
        print("Application shutting down...")
    }
}

// Entry point
print("Starting CalendarAPIBridge...")

// Create and configure the application
var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }

do {
    try CalendarAPIBridgeApp.configure(app)
    print("Starting server on http://localhost:8080...")
    try app.run()
} catch {
    print("Error starting application: \(error)")
} 