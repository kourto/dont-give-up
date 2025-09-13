//
//  Item.swift
//  dont-give-up
//
//  Created by Yves Courteau on 2025-09-13.
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
