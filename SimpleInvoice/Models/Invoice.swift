import SwiftData
import Foundation

@Model
final class Invoice {
    var id: UUID
    
    var client: Client?
    var issuedDate: Date
    var dueDate: Date
    var notes: String?

    var isPaid: Bool

    init(
        client: Client? = nil,
        issuedDate: Date = .now,
        dueDate: Date,
        notes: String? = nil,
        isPaid: Bool = false
    ) {
        self.id = UUID()
        self.client = client
        self.issuedDate = issuedDate
        self.dueDate = dueDate
        self.notes = notes
        self.isPaid = isPaid
    }
}