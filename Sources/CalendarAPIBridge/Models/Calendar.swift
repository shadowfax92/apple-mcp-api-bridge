import Foundation
import EventKit
import Vapor

// Calendar model for API responses
struct Calendar: Content {
    let id: String
    let title: String
    let color: String
    let isDefault: Bool
    let allowsModifications: Bool
    
    // Convert from EKCalendar to our Calendar model
    init(from ekCalendar: EKCalendar) {
        self.id = ekCalendar.calendarIdentifier
        self.title = ekCalendar.title
        self.color = ekCalendar.cgColor?.toHexString() ?? "#000000"
        // EKCalendar doesn't have isDefault property, so we'll check if it's the default calendar
        self.isDefault = ekCalendar == EKEventStore().defaultCalendarForNewEvents
        self.allowsModifications = ekCalendar.allowsContentModifications
    }
}

// Calendar creation request model
struct CalendarCreateRequest: Content {
    let title: String
    let color: String?
}

// Extension to convert CGColor to hex string
extension CGColor {
    func toHexString() -> String {
        guard let components = components, components.count >= 3 else {
            return "#000000"
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        let hex = String(
            format: "#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)
        )
        
        return hex
    }
} 