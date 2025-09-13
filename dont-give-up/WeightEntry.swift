//
//
//
//
//  Created by Yves Courteau on 2025-09-13.
//

import Foundation
import SwiftData

@Model
final class WeightEntry {
    var date: Date
    var weight: Double

    init(date: Date, weight: Double) {
        self.date = date
        self.weight = weight
    }
}
