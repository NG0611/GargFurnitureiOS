//
//  UserProfile.swift
//  GargFurniture
//
//  Created by Nikunj Garg on 19/11/25.
//

import Foundation

struct UserProfile: Codable {
    let uid: String
    var email: String
    var name: String
    var phone: String?
    var addresses: [Address]?  // uses Address from Address.swift

    init(
        uid: String,
        email: String,
        name: String = "",
        phone: String? = nil,
        addresses: [Address]? = nil
    ) {
        self.uid = uid
        self.email = email
        self.name = name
        self.phone = phone
        self.addresses = addresses
    }
}
