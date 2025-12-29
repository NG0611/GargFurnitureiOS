//
//  Product.swift
//  GargFurniture
//
//  Created by Nikunj Garg on 19/11/25.
//

import Foundation

struct Product: Identifiable {
    var id: String
    var name: String
    var price_cents: Int
    var currency: String
    var description: String
    var imageUrl: String?
    var stock: Int
}
