import Foundation
import Observation
import SwiftData

enum InvoiceStatusFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case open = "Open"
    case overdue = "Overdue"
    case paid = "Paid"
    var id: String { rawValue }
}

@Observable
final class InvoicesViewModel {

    var filter: InvoiceStatusFilter = .all
    var searchQuery: String = ""

    private(set) var displayed: [Invoice] = []
    private(set) var totalOutstanding: Double = 0

    func update(invoices: [Invoice],
                lineItems: [InvoiceLineItem],
                payments: [Payment]) {
        let now = Date.now

        for invoice in invoices {
            invoice.refreshOverdueStatus(referenceDate: now)
        }

        // Filter
        var result = invoices.filter { invoice in
            switch filter {
            case .all:     return true
            case .paid:    return invoice.status == .paid
            case .open:    return invoice.status == .sent || invoice.status == .draft
            case .overdue: return invoice.status == .overdue
            }
        }

        // Search
        if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            result = result.filter {
                $0.client?.name.localizedCaseInsensitiveContains(searchQuery) == true
            }
        }

        displayed = result

        // Total outstanding across ALL invoices (not just filtered)
        totalOutstanding = invoices
            .filter { $0.status != .paid }
            .reduce(0) {
                $0 + InvoiceCalculator.outstanding(for: $1,
                                                   lineItems: lineItems,
                                                   payments: payments)
            }
    }

    // Status transition validation
    func canMarkPaid(_ invoice: Invoice,
                     lineItems: [InvoiceLineItem],
                     payments: [Payment]) -> Bool {
        invoice.status != .paid &&
        InvoiceCalculator.total(for: invoice, lineItems: lineItems) > 0
    }

    func markPaid(_ invoice: Invoice, in modelContext: ModelContext) {
        invoice.status = .paid
        try? modelContext.save()
    }

    func isValidInvoiceInput(
        selectedClientID: UUID?,
        newClientName: String,
        lineItemTitle: String,
        unitPrice: Double,
        dueDate: Date
    ) -> Bool {
        let hasClient = selectedClientID != nil || !newClientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasLine = !lineItemTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasClient && hasLine && unitPrice > 0 && dueDate >= Calendar.current.startOfDay(for: .now)
    }
}