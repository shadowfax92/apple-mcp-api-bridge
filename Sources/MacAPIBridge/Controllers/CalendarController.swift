import Foundation
import Vapor
import EventKit
import AppKit

// Controller for calendar-related endpoints
class CalendarController {
    // Shared event store instance
    private let eventStore = EKEventStore()
    
    // GET /calendars - List all calendars
    func listCalendars(_ req: Request) async throws -> [Calendar] {
        // Get all calendars from the event store
        let calendars = eventStore.calendars(for: .event)
        
        // Convert EKCalendar objects to our Calendar model
        return calendars.map { Calendar(from: $0) }
    }
    
    // GET /calendars/:calendarId - Get calendar details
    func getCalendar(_ req: Request) async throws -> Calendar {
        // Get calendar ID from request parameters
        guard let calendarId = req.parameters.get("calendarId") else {
            throw Abort(.badRequest, reason: "Calendar ID is required")
        }
        
        // Find the calendar with the specified ID
        guard let calendar = findCalendar(withId: calendarId) else {
            throw Abort(.notFound, reason: "Calendar not found")
        }
        
        // Return the calendar
        return Calendar(from: calendar)
    }
    
    // POST /calendars - Create a new calendar
    func createCalendar(_ req: Request) async throws -> Calendar {
        // Decode request body
        let createRequest = try req.content.decode(CalendarCreateRequest.self)
        
        // Create a new calendar
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = createRequest.title
        
        // Set calendar color if provided
        if let colorHex = createRequest.color, let color = hexStringToNSColor(hex: colorHex) {
            newCalendar.cgColor = color.cgColor
        }
        
        // Set source (local or iCloud)
        if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
            newCalendar.source = localSource
        } else if let defaultSource = eventStore.defaultCalendarForNewEvents?.source {
            newCalendar.source = defaultSource
        } else {
            throw Abort(.internalServerError, reason: "No valid calendar source found")
        }
        
        // Save the calendar
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            return Calendar(from: newCalendar)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to create calendar: \(error.localizedDescription)")
        }
    }
    
    // DELETE /calendars/:calendarId - Delete a calendar
    func deleteCalendar(_ req: Request) async throws -> HTTPStatus {
        // Get calendar ID from request parameters
        guard let calendarId = req.parameters.get("calendarId") else {
            throw Abort(.badRequest, reason: "Calendar ID is required")
        }
        
        // Find the calendar with the specified ID
        guard let calendar = findCalendar(withId: calendarId) else {
            throw Abort(.notFound, reason: "Calendar not found")
        }
        
        // Check if the calendar can be removed
        guard calendar.allowsContentModifications else {
            throw Abort(.forbidden, reason: "This calendar cannot be modified")
        }
        
        // Delete the calendar
        do {
            try eventStore.removeCalendar(calendar, commit: true)
            return .ok
        } catch {
            throw Abort(.internalServerError, reason: "Failed to delete calendar: \(error.localizedDescription)")
        }
    }
    
    // Helper method to find a calendar by ID
    func findCalendar(withId id: String) -> EKCalendar? {
        return eventStore.calendars(for: .event).first { $0.calendarIdentifier == id }
    }
    
    // Helper method to convert hex color string to NSColor
    private func hexStringToNSColor(hex: String) -> NSColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        return NSColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
} 