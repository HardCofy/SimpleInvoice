import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Invoice.dueDate) private var invoices: [Invoice]
    @Query private var lineItems: [InvoiceLineItem]
    @Query private var expenses: [Expense]
    @Query private var payments: [Payment]

    @State private var vm = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dashboard")
                        .font(.largeTitle.bold())
                    Text(Date.now.formatted(.dateTime.month(.wide).year()))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    metricCard(title: "Income", value: vm.monthlyIncome.formattedCurrency, color: .green)
                    metricCard(title: "Expenses", value: vm.monthlyExpenses.formattedCurrency, color: .orange)
                }

                metricCard(
                    title: "Net",
                    value: vm.monthlyNet.formattedCurrency,
                    color: vm.monthlyNet >= 0 ? .green : .red
                )

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Outstanding Invoices")
                            .font(.title3.bold())
                        Spacer()
                        Text("\(vm.outstandingRows.count)")
                            .foregroundStyle(.secondary)
                    }

                    if vm.outstandingRows.isEmpty {
                        cardContainer {
                            Text("No outstanding invoices.")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(vm.outstandingRows, id: \.invoice.id) { row in
                            cardContainer {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(row.invoice.client?.name ?? "Unknown Client")
                                            .font(.headline)
                                        Text("Due \(row.invoice.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(row.amount.formattedCurrency)
                                        .font(.headline)
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .onChange(of: invoiceChangeToken)  { recompute() }
        .onChange(of: lineItemChangeToken) { recompute() }
        .onChange(of: expenseChangeToken)  { recompute() }
        .onChange(of: paymentChangeToken)  { recompute() }
        .onAppear { recompute() }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func recompute() {
        vm.update(invoices: invoices, lineItems: lineItems,
                  expenses: expenses, payments: payments)
    }

    private func metricCard(title: String, value: String, color: Color) -> some View {
        cardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var invoiceChangeToken: [String] {
        invoices.map { "\($0.id.uuidString)|\($0.status.rawValue)|\($0.dueDate.timeIntervalSince1970)" }
    }

    private var lineItemChangeToken: [String] {
        lineItems.map { "\($0.id.uuidString)|\($0.quantity)|\($0.unitPrice)" }
    }

    private var expenseChangeToken: [String] {
        expenses.map { "\($0.id.uuidString)|\($0.amount)|\($0.date.timeIntervalSince1970)" }
    }

    private var paymentChangeToken: [String] {
        payments.map { "\($0.id.uuidString)|\($0.amount)|\($0.date.timeIntervalSince1970)" }
    }
}

private func cardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    content()
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
}