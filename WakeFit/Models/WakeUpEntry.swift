//
//  WakeUpEntry.swift
//  WakeFit
//
//  SwiftData model for daily wake-up time tracking
//

import Foundation
import SwiftData

@Model  // Makes this class storable in SwiftData
final class WakeUpEntry {
    var id: UUID
    var date: Date               // Calendar date (for grouping by day)
    var wakeUpTime: Date         // Actual timestamp when user logged wake-up

    init(
        id: UUID = UUID(),
        date: Date,
        wakeUpTime: Date
    ) {
        self.id = id
        self.date = date
        self.wakeUpTime = wakeUpTime
    }
}
