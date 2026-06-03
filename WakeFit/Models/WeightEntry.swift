//
//  WeightEntry.swift
//  WakeFit
//
//  SwiftData model for tracking weight measurements over time
//

import Foundation
import SwiftData

@Model  // Makes this class storable in SwiftData
final class WeightEntry {
    var id: UUID
    var date: Date               // When weight was recorded
    var weight: Double           // Weight in kilograms

    init(
        id: UUID = UUID(),
        date: Date,
        weight: Double
    ) {
        self.id = id
        self.date = date
        self.weight = weight
    }
}
