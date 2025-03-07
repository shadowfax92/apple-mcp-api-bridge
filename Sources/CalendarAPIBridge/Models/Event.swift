import Foundation
import EventKit
import Vapor

// Event model for API responses
struct Event: Content {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let location: String?
    let notes: String?
    let url: URL?
    let calendarId: String
    
    // Convert from EKEvent to our Event model
    init(from ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier ?? UUID().uuidString
        self.title = ekEvent.title ?? "Untitled Event"
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.isAllDay = ekEvent.isAllDay
        self.location = ekEvent.location
        self.notes = ekEvent.notes
        self.url = ekEvent.url
        self.calendarId = ekEvent.calendar.calendarIdentifier
    }
}

// Event creation/update request model
struct EventRequest: Content {
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool?
    let location: String?
    let notes: String?
    let url: String?
    
    // Convert to EKEvent
    func toEKEvent(eventStore: EKEventStore, calendar: EKCalendar) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay ?? false
        event.location = location
        event.notes = notes
        if let urlString = url, let url = URL(string: urlString) {
            event.url = url
        }
        event.calendar = calendar
        
        return event
    }
} 