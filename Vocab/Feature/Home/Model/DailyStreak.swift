//
//  DailyStreak.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import Foundation
import SwiftData

@Model
class DailyStreak {
    @Attribute(.unique)
    var dateString: String // "yyyy-MM-dd"
    
    var timestamp: Date
    
    init(date: Date = .now) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.dateString = formatter.string(from: date)
        self.timestamp = date
    }
}
