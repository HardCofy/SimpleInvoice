import SwiftData
import Foundation

enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case bankTransfer
    case card
    case cash
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .bankTransfer: return "Bank Transfer"
        case .card: return "Card"
        case .cash: return "Cash"
        case .other: return "Other"
        }
    }
}

@Model
final class Payment {

    var id: UUID

    var invoice: Invoice?
    var amount: Double
    var date: Date
    var notes: String?
    var method: PaymentMethod

    init(
        invoice: Invoice? = nil,
        amount: Double,
        date: Date = .now,
        notes: String? = nil,
        method: PaymentMethod = .bankTransfer
    ) {
        self.id = UUID()
        self.invoice = invoice
        self.amount = amount
        self.date = date
        self.notes = notes
        self.method = method
    }
}