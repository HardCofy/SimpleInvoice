import Foundation

/// Pure functions — no SwiftData imports, fully unit-testable.
enum InvoiceCalculator {
    static func subtotal(for invoice: Invoice, lineItems: [InvoiceLineItem]) -> Double {
        lineItems
            .filter { $0.invoice?.id == invoice.id }
            .reduce(0) { $0 + Double($1.quantity) * $1.unitPrice }
    }

    static func taxAmount(subtotal: Double, taxRate: Double) -> Double {
        max(0, subtotal * (taxRate / 100))
    }

    static func total(for invoice: Invoice, lineItems: [InvoiceLineItem]) -> Double {
        let base = subtotal(for: invoice, lineItems: lineItems)
        return base + taxAmount(subtotal: base, taxRate: invoice.taxRate)
    }

    static func paid(for invoice: Invoice, payments: [Payment]) -> Double {
        payments
            .filter { $0.invoice?.id == invoice.id }
            .reduce(0) { $0 + $1.amount }
    }

    static func outstanding(for invoice: Invoice,
                            lineItems: [InvoiceLineItem],
                            payments: [Payment]) -> Double {
        max(0, total(for: invoice, lineItems: lineItems) - paid(for: invoice, payments: payments))
    }
}