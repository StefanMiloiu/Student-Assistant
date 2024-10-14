//
//  ModelExtensions.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import Foundation
import SwiftUI

enum ColorsManager {
    case green
    case red
    case blue
    case custom(Color) // Associated value for custom colors

    // Computed property to return a Color for each case
    var color: Color {
        switch self {
        case .green:
            return Color.green
        case .red:
            return Color.red
        case .blue:
            return Color.blue
        case .custom(let color):
            return color
        }
    }
}
