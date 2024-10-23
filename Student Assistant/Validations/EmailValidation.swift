//
//  EmailValidation.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 23.10.2024.
//

import Foundation

struct EmailValidation {
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
}
