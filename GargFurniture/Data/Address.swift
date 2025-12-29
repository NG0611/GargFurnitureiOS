import Foundation

struct Address: Identifiable, Codable {
    var id: String = UUID().uuidString
    var label: String
    var line1: String
    var city: String
    var state: String
    var pincode: String
    var phone: String
}
