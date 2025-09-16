//
//
//
//
//  Created by Yves Courteau on 2025-09-15.
//

import Foundation
import SwiftData

@Model
final class Objective {
    var weight: Double
    var createdAt: Date
    var reachedAt: Date?

    init(weight: Double, createdAt: Date = Date(), reachedAt: Date? = nil) {
        self.weight = weight
        self.createdAt = createdAt
        self.reachedAt = reachedAt
    }
}
