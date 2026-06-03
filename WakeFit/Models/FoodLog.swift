//
//  FoodLog.swift
//  WakeFit
//
//  SwiftData model for food logging across time blocks
//

import Foundation
import SwiftData

@Model  // Makes this class storable in SwiftData
final class FoodLog {
    var id: UUID
    var date: Date               // Calendar date (which day)
    var timeBlock: String        // "morning", "afternoon", or "evening"
    var foodText: String         // What user ate (text or speech-to-text)
    var entryTime: Date          // When this food was logged

    init(
        id: UUID = UUID(),
        date: Date,
        timeBlock: String,
        foodText: String,
        entryTime: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.timeBlock = timeBlock
        self.foodText = foodText
        self.entryTime = entryTime
    }
}
