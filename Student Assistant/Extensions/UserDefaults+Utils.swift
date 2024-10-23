//
//  UserDefaults+Utils.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//

import Foundation

extension UserDefaults {

   /**
    Returns the decodable value associated with the specified key.

    - Parameters:
         - type: Type of the expected decocable value
         - key: A key in the current user‘s defaults database.
    */
   func decodable<T>(type: T.Type, for key: String) -> T? where T: Decodable {
       guard let data = object(forKey: key) as? Data else { return nil }

       return try? JSONDecoder().decode(T.self, from: data)
   }

   /**
    Sets the value of the specified default key to the specified encodable value.

    - Parameters:
         - value: The integer value to store in the defaults database.
         - defaultName: The key with which to associate the value.
    */
   @discardableResult
   func set<T>(encodable: T, forKey defaultName: String) -> Bool where T: Encodable {
       guard let data = try? JSONEncoder().encode(encodable) else {
           return false
       }

       set(data, forKey: defaultName)
       return true
   }
}
