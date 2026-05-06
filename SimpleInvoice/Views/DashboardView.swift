import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Invoice.dueDate) private var invoices: [Invoice]
    @Query private var lineItems: [InvoiceLineItem]
    @Query private var expenses: [Expense]
    @Query private var payments: [Payment]

    private var monthLabel: String {
        Date.now.formatted(.dateTime.month(.wide).year())
    }

    private var monthlyIncome: Double {
        payments
            .filter { Calendar.current.isDate($0.date, equalTo: Date.now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    private var monthlyExpenses: Double {
        expenses
            .filter { Calendar.current.isDate($0.date, equalTo: Date.now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    private var outstandingInvoices: [(invoice: Invoice, amount: Double)] {
        invoices.compactMap { invoice in
            guard !invoice.isPaid else { return nil }
            let invoiceId = invoice.id

            let total = lineItems
                .filter { $0.invoice?.id == invoiceId }
                .reduce(0) { $0 + (Double($1.quantity) * $1.unitPrice) }

            let paid = payments
                .filter { $0.invoice?.id == invoiceId }
                .reduce(0) { $0 + $1.amount }

            let outstanding = max(0, total - paid)
            guard outstanding > 0 else { return nil }
            return (invoice, outstanding)
        }
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private func money(_ value: Double) -> String {
        value.formatted(.currency(code: currencyCode))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dashboard")
                        .font(.largeTitle.bold())
                    Text(monthLabel)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    metricCard(
                        title: "Income",
                        value: money(monthlyIncome),
                        icon: "arrow.down.left.circle.fill",
                        iconColor: .green
                    )

                    metricCard(
                        title: "Expenses",
                        value: money(monthlyExpenses),
                        icon: "arrow.up.right.circle.fill",
                        iconColor: .orange
                    )
                }

                netCard

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Outstanding Invoices")
                            .font(.title3.bold())
                        Spacer()
                        Text("\(outstandingInvoices.count)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    if outstandingInvoices.isEmpty {
                        cardContainer {
                            Text("No outstanding invoices this month.")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(outstandingInvoices, id: \.invoice.id) { row in
                            outstandingRow(invoice: row.invoice, outstanding: row.amount)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var netCard: some View {
        let net = monthlyIncome - monthlyExpenses
        let denominator = max(monthlyIncome, 1)
        let ratio = min(max(monthlyExpenses / denominator, 0), 1)

        return cardContainer {
            VStack(alignment: .leading, spacing: 14) {
                Text("Monthly Health")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(money(net))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text(net >= 0 ? "net positive" : "net negative")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(net >= 0 ? .green : .red)
                }

                VStack(alignment: .leading, spacing: 6) {
                    ProgressView(value: ratio)
                        .tint(.purple)
                    Text("Expense ratio: \(Int(ratio * 100))% of income")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func metricCard(title: String, value: String, icon: String, iconColor: Color) -> some View {
        cardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func outstandingRow(invoice: Invoice, outstanding: Double) -> some View {
        cardContainer {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.black.opacity(0.08))
                    .frame(width: 38, height: 38)
                    .overlay {
                        Text(String((invoice.client?.name ?? "U").prefix(1)).uppercased())
                            .font(.headline.weight(.semibold))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(invoice.client?.name ?? "Unknown Client")
                        .font(.headline)
                    Text("Due \(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(money(outstanding))
                    .font(.headline.bold())
                    .foregroundStyle(.red)
            }
        }
    }
}

private func cardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    content()
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
}
