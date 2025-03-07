import Vapor
import EventKit

// Configure and start the application
struct CalendarAPIBridgeApp {
    static func main() async throws {
        // Create and configure Vapor application
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        // Use the async version of Application creation
        let app = try await Application.make(env)
        
        // Configure routes
        try configureRoutes(app)
        
        // Request calendar access
        try await requestCalendarAccess()
        
        // Start the server using the async execute method
        try await app.execute()
    }
    
    // Request access to the Calendar
    static func requestCalendarAccess() async throws {
        let eventStore = EKEventStore()
        
        // Request access to the Calendar
        let accessGranted = await withCheckedContinuation { continuation in
            eventStore.requestAccess(to: .event) { granted, error in
                if let error = error {
                    print("Error requesting Calendar access: \(error.localizedDescription)")
                }
                continuation.resume(returning: granted)
            }
        }
        
        guard accessGranted else {
            throw Abort(.internalServerError, reason: "Calendar access denied. Please grant access in System Preferences.")
        }
        
        print("Calendar access granted!")
    }
    
    // Configure all routes
    static func configureRoutes(_ app: Application) throws {
        // Register controllers
        try registerCalendarController(app)
        try registerEventController(app)
    }
    
    // Register calendar-related routes
    static func registerCalendarController(_ app: Application) throws {
        let calendarController = CalendarController()
        
        let calendarsGroup = app.grouped("calendars")
        
        // GET /calendars - List all calendars
        calendarsGroup.get { req in
            try await calendarController.listCalendars(req)
        }
        
        // GET /calendars/:id - Get calendar details
        calendarsGroup.get(":id") { req in
            try await calendarController.getCalendar(req)
        }
        
        // POST /calendars - Create a new calendar
        calendarsGroup.post { req in
            try await calendarController.createCalendar(req)
        }
        
        // DELETE /calendars/:id - Delete a calendar
        calendarsGroup.delete(":id") { req in
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

// Entry point
Task {
    do {
        try await CalendarAPIBridgeApp.main()
    } catch {
        print("Error starting application: \(error)")
        exit(1)
    }
} 