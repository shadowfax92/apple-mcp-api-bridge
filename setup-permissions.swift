#!/usr/bin/swift

import Foundation
import EventKit

print("Calendar API Bridge - Permission Setup")
print("=====================================")
print("This script will request access to your macOS Calendar.")
print("Please grant access when prompted.")
print()

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

print("Requesting Calendar access...")
eventStore.requestAccess(to: .event) { granted, error in
    if granted {
        print("✅ Calendar access granted successfully!")
    } else {
        if let error = error {
            print("❌ Error requesting Calendar access: \(error.localizedDescription)")
        } else {
            print("❌ Calendar access was denied.")
            print("Please go to System Preferences > Security & Privacy > Privacy > Calendars")
            print("and check the box next to CalendarAPIBridge.")
        }
    }
    semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
print()
print("Setup complete. You can now run the CalendarAPIBridge application.") 