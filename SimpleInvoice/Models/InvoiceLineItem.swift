import SwiftData
import Foundation

@Model
final class InvoiceLineItem {

    var id: UUID

    // Relationship
    var invoice: Invoice?

    var title: String
    var quantity: Int
    var unitPrice: Double

    init(
        invoice: Invoice? = nil,
        title: String,
        quantity: Int,
        unitPrice: Double
    ) {
        self.id = UUID()
        self.invoice = invoice
        self.title = title
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}