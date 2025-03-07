import Foundation
import Vapor
import EventKit

// Controller for event-related endpoints
class EventController {
    // Shared event store instance
    private let eventStore = EKEventStore()
    
    // Calendar controller for finding calendars
    private let calendarController = CalendarController()
    
    // GET /calendars/:calendarId/events - List events in a calendar
    func listEvents(_ req: Request) async throws -> [Event] {
        // Get calendar ID from request parameters
        guard let calendarId = req.parameters.get("calendarId") else {
            throw Abort(.badRequest, reason: "Calendar ID is required")
        }
        
        // Find the calendar with the specified ID
        guard let calendar = calendarController.findCalendar(withId: calendarId) else {
            throw Abort(.notFound, reason: "Calendar not found")
        }
        
        // Create a predicate for events in the specified calendar
        let startDate = Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30 days ago
        let endDate = Date().addingTimeInterval(365 * 24 * 60 * 60) // 1 year from now
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        
        // Get events matching the predicate
        let events = eventStore.events(matching: predicate)
        
        // Convert EKEvent objects to our Event model
        return events.map { Event(from: $0) }
    }
    
    // GET /calendars/:calendarId/events/:eventId - Get event details
    func getEvent(_ req: Request) async throws -> Event {
        // Get calendar ID and event ID from request parameters
        guard let calendarId = req.parameters.get("calendarId") else {
            throw Abort(.badRequest, reason: "Calendar ID is required")
        }
        
        guard let eventId = req.parameters.get("eventId") else {
            throw Abort(.badRequest, reason: "Event ID is required")
        }
        
        // Check if the calendar exists
        guard calendarController.findCalendar(withId: calendarId) != nil else {
            throw Abort(.notFound, reason: "Calendar not found")
        }
        
        // Find the event with the specified ID
        guard let event = eventStore.event(withIdentifier: eventId) else {
            throw Abort(.notFound, reason: "Event not found")
        }
        
        // Check if the event belongs to the specified calendar
        guard event.calendar.calendarIdentifier == calendarId else {
            throw Abort(.notFound, reason: "Event not found in the specified calendar")
        }
        
        // Return the event
        return Event(from: event)
    }
    
    // POST /calendars/:calendarId/events - Create a new event
    func createEvent(_ req: Request) async throws -> Event {
        // Get calendar ID from request parameters
        guard let calendarId = req.parameters.get("calendarId") else {
            throw Abort(.badRequest, reason: "Calendar ID is required")
        }
        
        // Find the calendar with the specified ID
        guard let calendar = calendarController.findCalendar(withId: calendarId) else {
            throw Abort(.notFound, reason: "Calendar not found")
        }
        
        // Check if the calendar allows modifications
        guard calendar.allowsContentModifications else {
            throw Abort(.forbidden, reason: "This calendar does not allow modifications")
        }
        
        // Decode request body
        let eventRequest = try req.content.decode(EventRequest.self)
        
        // Create a new event
        let newEvent = eventRequest.toEKEvent(eventStore: eventStore, calendar: calendar)
        
        // Save the event
        do {
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
            return Event(from: newEvent)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to create event: \(error.localizedDescription)")
        }
    }
    
    // PUT /calendars/:calendarId/events/:eventId - Update an event
    func updateEvent(_ req: Request) async throws -> Event {
        // Get calendar ID and event ID from request parameters
        guard let calendarId = req.parameters.get("calendarId") else {
            throw Abort(.badRequest, reason: "Calendar ID is required")
        }
        
        guard let eventId = req.parameters.get("eventId") else {
            throw Abort(.badRequest, reason: "Event ID is required")
        }
        
        // Find the calendar with the specified ID
        guard let calendar = calendarController.findCalendar(withId: calendarId) else {
            throw Abort(.notFound, reason: "Calendar not found")
        }
        
        // Check if the calendar allows modifications
        guard calendar.allowsContentModifications else {
            throw Abort(.forbidden, reason: "This calendar does not allow modifications")
        }
        
        // Find the event with the specified ID
        guard let existingEvent = eventStore.event(withIdentifier: eventId) else {
            throw Abort(.notFound, reason: "Event not found")
        }
        
        // Check if the event belongs to the specified calendar
        guard existingEvent.calendar.calendarIdentifier == calendarId else {
            throw Abort(.notFound, reason: "Event not found in the specified calendar")
        }
        
        // Decode request body
        let eventRequest = try req.content.decode(EventRequest.self)
        
        // Update the event
        existingEvent.title = eventRequest.title
        existingEvent.startDate = eventRequest.startDate
        existingEvent.endDate = eventRequest.endDate
        existingEvent.isAllDay = eventRequest.isAllDay ?? existingEvent.isAllDay
        existingEvent.location = eventRequest.location
        existingEvent.notes = eventRequest.notes
        if let urlString = eventRequest.url, let url = URL(string: urlString) {
            existingEvent.url = url
        }
        
        // Save the updated event
        do {
            try eventStore.save(existingEvent, span: .thisEvent, commit: true)
            return Event(from: existingEvent)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to update event: \(error.localizedDescription)")
        }
    }
    
    // DELETE /calendars/:calendarId/events/:eventId - Delete an event
    func deleteEvent(_ req: Request) async throws -> HTTPStatus {
        // Get calendar ID and event ID from request parameters
        guard let calendarId = req.parameters.get("calendarId") else {
            throw Abort(.badRequest, reason: "Calendar ID is required")
        }
        
        guard let eventId = req.parameters.get("eventId") else {
            throw Abort(.badRequest, reason: "Event ID is required")
        }
        
        // Find the calendar with the specified ID
        guard let calendar = calendarController.findCalendar(withId: calendarId) else {
            throw Abort(.notFound, reason: "Calendar not found")
        }
        
        // Check if the calendar allows modifications
        guard calendar.allowsContentModifications else {
            throw Abort(.forbidden, reason: "This calendar does not allow modifications")
        }
        
        // Find the event with the specified ID
        guard let event = eventStore.event(withIdentifier: eventId) else {
            throw Abort(.notFound, reason: "Event not found")
        }
        
        // Check if the event belongs to the specified calendar
        guard event.calendar.calendarIdentifier == calendarId else {
            throw Abort(.notFound, reason: "Event not found in the specified calendar")
        }
        
        // Delete the event
        do {
            try eventStore.remove(event, span: .thisEvent, commit: true)
            return .ok
        } catch {
            throw Abort(.internalServerError, reason: "Failed to delete event: \(error.localizedDescription)")
        }
    }
} 