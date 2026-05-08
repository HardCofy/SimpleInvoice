import SwiftData
import Foundation

enum InvoiceStatus: String, Codable, CaseIterable, Identifiable {
    case draft
    case sent
    case overdue
    case paid

    var id: String { rawValue }
}

@Model
final class Invoice {
    var id: UUID
    var client: Client?
    var issuedDate: Date
    var dueDate: Date
    var notes: String?
    var status: InvoiceStatus
    var taxRate: Double

    @Relationship(deleteRule: .cascade, inverse: \InvoiceLineItem.invoice)
    var lineItems: [InvoiceLineItem]
    @Relationship(deleteRule: .cascade, inverse: \Payment.invoice)
    var payments: [Payment]

    init(
        client: Client? = nil,
        issuedDate: Date = .now,
        dueDate: Date,
        notes: String? = nil,
        status: InvoiceStatus = .draft,
        taxRate: Double = 0
    ) {
        self.id = UUID()
        self.client = client
        self.issuedDate = issuedDate
        self.dueDate = dueDate
        self.notes = notes
        self.status = status
        self.taxRate = taxRate
        self.lineItems = []
        self.payments = []
    }

    var subtotal: Double {
        lineItems.reduce(0) { $0 + (Double($1.quantity) * $1.unitPrice) }
    }

    var taxAmount: Double {
        max(0, subtotal * (taxRate / 100))
    }

    var total: Double {
        subtotal + taxAmount
    }

    var paidAmount: Double {
        payments.reduce(0) { $0 + $1.amount }
    }

    var outstandingAmount: Double {
        max(0, total - paidAmount)
    }

    func refreshOverdueStatus(referenceDate: Date = .now) {
        guard status != .paid else { return }
        status = dueDate < referenceDate ? .overdue : .sent
    }
}