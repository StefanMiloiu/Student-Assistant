//
//  UserDefaultsManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//

import Foundation

extension UserDefaults {
    
    /// Struct that contains keys for storing user-related data in `UserDefaults`.
    private struct Keys {
        static let userName = "userName"         /// Key for storing the user's name.
        static let isLoggedIn = "isLoggedIn"     /// Key for storing the user's login status.
    }

    // MARK: - User Defaults Properties

    /// Computed property for storing and retrieving the user's name from `UserDefaults`.
    /// - Returns: A `String?` containing the user's name, or `nil` if not set.
    var userName: String? {
        get { decodable(type: String.self, for: Keys.userName) }
        set { set(encodable: newValue, forKey: Keys.userName) }
    }

    /// Computed property for storing and retrieving the user's login status from `UserDefaults`.
    /// - Returns: A `Bool` indicating whether the user is logged in (`true`) or not (`false`).
    var isLoggedIn: Bool {
        get { bool(forKey: Keys.isLoggedIn) }
        set { setValue(newValue, forKey: Keys.isLoggedIn) }
    }
}
