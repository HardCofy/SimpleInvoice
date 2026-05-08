import SwiftData
import Foundation

enum ClientType: String, Codable, CaseIterable, Identifiable {
    case individual
    case business

    var id: String { rawValue }
}

@Model
final class Client {
    var id: UUID
    var name: String
    var email: String?
    var notes: String?
    var type: ClientType

    init(
        name: String,
        email: String? = nil,
        notes: String? = nil,
        type: ClientType = .individual
    ) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.notes = notes
        self.type = type
    }
}