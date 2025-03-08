import Foundation
import EventKit
import Vapor

// Custom date decoder that supports multiple formats
struct FlexibleDateDecoder: ContentDecoder {
    struct FlexibleDateDecodingError: Error {
        let message: String
    }
    
    func decode<D>(_ decodable: D.Type, from body: ByteBuffer, headers: HTTPHeaders) throws -> D where D: Decodable {
        let data = Data(buffer: body)
        let decoder = JSONDecoder()
        
        // Set up a custom date decoding strategy
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try ISO8601 with milliseconds and Z timezone
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
                        // Try multiple other date formats
            let dateFormatters: [DateFormatter] = [
                // ISO8601 without milliseconds
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }(),
                
                // ISO8601 with space instead of T
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }()
            ]
            
            // Try each formatter
            for formatter in dateFormatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            // If we get here, none of the formatters worked
            throw FlexibleDateDecodingError(message: "Invalid date format. Please use one of these formats:\n1. ISO8601 with UTC timezone (Z): 2025-03-09T10:00:00.000Z\n2. ISO8601 without milliseconds: 2025-03-09T10:00:00\n3. ISO8601 with space: 2025-03-09 10:00:00\n\nReceived: \(dateString)")
        }
        
        return try decoder.decode(D.self, from: data)
    }
}

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