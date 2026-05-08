import Foundation
import Observation

@Observable
final class DashboardViewModel {

    // MARK: - Derived state (set by the view after each @Query update)
    private(set) var monthlyIncome: Double = 0
    private(set) var monthlyExpenses: Double = 0
    private(set) var outstandingRows: [(invoice: Invoice, amount: Double)] = []

    var monthlyNet: Double { monthlyIncome - monthlyExpenses }
    var expenseRatio: Double { monthlyIncome > 0 ? min(monthlyExpenses / monthlyIncome, 1) : 0 }

    // MARK: - Called by the view whenever @Query data changes
    func update(invoices: [Invoice],
                lineItems: [InvoiceLineItem],
                expenses: [Expense],
                payments: [Payment]) {

        let now = Date.now

        monthlyIncome = payments
            .filter { Calendar.current.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }

        monthlyExpenses = expenses
            .filter { Calendar.current.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }

        outstandingRows = invoices.compactMap { invoice in
            guard invoice.status != .paid else { return nil }
            let amount = InvoiceCalculator.outstanding(for: invoice,
                                                       lineItems: lineItems,
                                                       payments: payments)
            return amount > 0 ? (invoice, amount) : nil
        }
    }
}