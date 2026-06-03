//
//  SleepEntry.swift
//  WakeFit
//
//  SwiftData model for tracking nightly sleep discipline
//

import Foundation
import SwiftData

@Model  // Makes this class storable in SwiftData
final class SleepEntry {
    var id: UUID
    var date: Date               // Calendar date (which night)
    var sleptOnTime: Bool        // Did user sleep before 11:50 PM?
    var notes: String            // Optional user notes

    init(
        id: UUID = UUID(),
        date: Date,
        sleptOnTime: Bool,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.sleptOnTime = sleptOnTime
        self.notes = notes
    }
}
