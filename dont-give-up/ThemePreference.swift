//
//
//
//
//  Created by Yves Courteau on 2025-09-13.
//

import Foundation
import SwiftData

@Model
final class ThemePreference {
    var isDarkMode: Bool

    init(isDarkMode: Bool = false) {
        self.isDarkMode = isDarkMode
    }
}
