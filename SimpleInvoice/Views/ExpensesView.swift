import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var showingCreateExpense = false

    var body: some View {
        List {
            if expenses.isEmpty {
                ContentUnavailableView(
                    "No expenses yet",
                    systemImage: "creditcard",
                    description: Text("Add your first expense to track monthly costs.")
                )
            } else {
                ForEach(expenses) { expense in
                    NavigationLink {
                        ExpenseFormView(expense: expense)
                    } label: {
                        expenseRow(expense)
                    }
                }
                .onDelete(perform: deleteExpenses)
            }
        }
        .navigationTitle("Expenses")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateExpense = true
                } label: {
                    Label("New Expense", systemImage: "plus")
                }
                .accessibilityIdentifier("expenses.new")
            }
        }
        .sheet(isPresented: $showingCreateExpense) {
            NavigationStack {
                ExpenseFormView()
            }
        }
    }

    private func expenseRow(_ expense: Expense) -> some View {
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(expense.title)
                    .font(.headline)
                Spacer()
                Text(expense.amount.formattedCurrency)
                    .font(.headline)
            }

            HStack {
                Text(expense.category.label)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(expenses[index])
        }

        try? modelContext.save()
    }
}

private struct ExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let expense: Expense?
    @State private var vm = ExpensesViewModel()

    @State private var title = ""
    @State private var category: ExpenseCategory = .software
    @State private var amount = 0.0
    @State private var date = Date.now

    init(expense: Expense? = nil) {
        self.expense = expense
    }

    var body: some View {
        Form {
            Section("Expense") {
                TextField("Title", text: $title)
                    .accessibilityIdentifier("expense.title")

                Picker("Category", selection: $category) {
                    ForEach(ExpenseCategory.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .accessibilityIdentifier("expense.category")

                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("0.00", value: $amount, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 120)
                        .accessibilityIdentifier("expense.amount")
                }

                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .accessibilityIdentifier("expense.date")
            }
        }
        .navigationTitle(expense == nil ? "New Expense" : "Edit Expense")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { save() }
                    .disabled(!canSave)
                    .accessibilityIdentifier("expense.save")
            }
        }
        .onAppear(perform: loadInitialValues)
    }

    private var canSave: Bool {
        vm.isValidExpenseInput(title: title, amount: amount)
    }

    private func loadInitialValues() {
        guard let expense else { return }
        title = expense.title
        category = expense.category
        amount = expense.amount
        date = expense.date
    }

    private func save() {
        if let expense {
            expense.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            expense.category = category
            expense.amount = amount
            expense.date = date
        } else {
            let created = Expense(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category,
                amount: amount,
                date: date
            )
            modelContext.insert(created)
        }

        try? modelContext.save()
        dismiss()
    }
}
