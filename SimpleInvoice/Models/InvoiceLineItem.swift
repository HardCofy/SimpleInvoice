import SwiftData
import Foundation

enum InvoiceLineItemUnit: String, Codable, CaseIterable, Identifiable {
    case item
    case hour
    case day
    case service

    var id: String { rawValue }
}

@Model
final class InvoiceLineItem {

    var id: UUID

    var invoice: Invoice?
    var title: String
    var quantity: Int
    var unitPrice: Double
    var unit: InvoiceLineItemUnit

    init(
        invoice: Invoice? = nil,
        title: String,
        quantity: Int,
        unitPrice: Double,
        unit: InvoiceLineItemUnit = .item
    ) {
        self.id = UUID()
        self.invoice = invoice
        self.title = title
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.unit = unit
    }

    var lineTotal: Double {
        max(0, Double(quantity) * unitPrice)
    }
}