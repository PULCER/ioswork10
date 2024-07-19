//
//  Item.swift
//  Work 10
//
//  Created by Anthony Howell on 7/19/24.
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
