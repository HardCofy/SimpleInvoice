import SwiftData
import Foundation

@Model
final class Payment {

    var id: UUID

    //Realtionship
    var invoice: Invoice?

    var amount: Double
    var date: Date
    var notes: String?

    init(
        invoice: Invoice? = nil,
        amount: Double,
        date: Date = .now,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.invoice = invoice
        self.amount = amount
        self.date = date
        self.notes = notes
    }
}