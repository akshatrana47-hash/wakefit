//
//  Item.swift
//  WakeFit
//
//  Created by Akshat Rana on 2026-06-03.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
