import SwiftData
import Foundation

@Model
final class Client {
    var id: UUID
    var name: String
    var email: String?
    var notes: String?

    init(
        name: String,
        email: String? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.notes = notes
    }
}