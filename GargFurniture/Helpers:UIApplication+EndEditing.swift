//
//  Helpers:UIApplication+EndEditing.swift
//  GargFurniture
//
//  Created by Nikunj Garg on 19/11/25.
//

// UIApplication+EndEditing.swift
import UIKit

extension UIApplication {
    /// Dismiss keyboard from anywhere.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
