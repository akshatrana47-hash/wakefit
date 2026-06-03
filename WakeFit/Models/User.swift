//
//  User.swift
//  WakeFit
//
//  SwiftData model for user profile and fitness goals
//

import Foundation
import SwiftData

@Model  // Makes this class storable in SwiftData
final class User {
    var id: UUID
    var name: String
    var email: String
    var startingWeight: Double   // kg
    var targetWeight: Double     // kg
    var height: Double           // cm
    var startDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        startingWeight: Double,
        targetWeight: Double,
        height: Double,
        startDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.startingWeight = startingWeight
        self.targetWeight = targetWeight
        self.height = height
        self.startDate = startDate
    }
}
