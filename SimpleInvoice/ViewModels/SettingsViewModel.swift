import Foundation
import Observation
import SwiftData

@Observable
final class SettingsViewModel {
    struct DataSummary {
        let clients: Int
        let invoices: Int
        let expenses: Int
    }

    private(set) var paymentsTotal: Double = 0
    private(set) var outstandingTotal: Double = 0
    private(set) var summary = DataSummary(clients: 0, invoices: 0, expenses: 0)
    let privacyMessage = "Your data is stored only on this device using local SwiftData storage. No cloud sync, analytics, or third-party trackers are enabled."

    func update(clients: [Client],
                invoices: [Invoice],
                expenses: [Expense],
                lineItems: [InvoiceLineItem],
                payments: [Payment]) {
        summary = DataSummary(clients: clients.count, invoices: invoices.count, expenses: expenses.count)
        paymentsTotal = payments.reduce(0) { $0 + $1.amount }
        outstandingTotal = invoices.reduce(0) {
            $0 + InvoiceCalculator.outstanding(for: $1,
                                               lineItems: lineItems,
                                               payments: payments)
        }
    }

    func clearAllData(
        modelContext: ModelContext,
        clients: [Client],
        invoices: [Invoice],
        expenses: [Expense],
        lineItems: [InvoiceLineItem],
        payments: [Payment]
    ) {
        for item in lineItems { modelContext.delete(item) }
        for payment in payments { modelContext.delete(payment) }
        for invoice in invoices { modelContext.delete(invoice) }
        for expense in expenses { modelContext.delete(expense) }
        for client in clients { modelContext.delete(client) }
        try? modelContext.save()
    }
}