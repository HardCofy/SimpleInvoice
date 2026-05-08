import Foundation
import Observation

@Observable
final class ExpensesViewModel {

    var selectedCategory: ExpenseCategory? = nil
    var selectedMonth: Date = .now

    private(set) var filtered: [Expense] = []
    private(set) var totalForPeriod: Double = 0
    private(set) var categoryBreakdown: [(category: ExpenseCategory, total: Double)] = []

    func update(expenses: [Expense]) {
        let inMonth = expenses.filter {
            Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)
        }

        filtered = selectedCategory != nil
            ? inMonth.filter { $0.category == selectedCategory }
            : inMonth

        totalForPeriod = filtered.reduce(0) { $0 + $1.amount }

        // Group by category for a potential chart
        let groups = Dictionary(grouping: inMonth, by: \.category)
        categoryBreakdown = groups
            .map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    func isValidExpenseInput(title: String, amount: Double) -> Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && amount > 0
    }
}