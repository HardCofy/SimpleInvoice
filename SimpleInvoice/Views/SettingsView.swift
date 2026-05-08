import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @AppStorage("app.themePreference") private var themePreference = ThemePreference.system.rawValue
    @AppStorage("app.currencyCode") private var currencyCode = "USD"
    @AppStorage("app.defaultInvoiceDueDays") private var defaultInvoiceDueDays = 14
    @AppStorage("app.defaultTaxRate") private var defaultTaxRate = 0.0
    @AppStorage("app.remindUpcomingDue") private var remindUpcomingDue = true
    @AppStorage("app.showPaidOnDashboard") private var showPaidOnDashboard = true

    @Query(sort: \Client.name) private var clients: [Client]
    @Query(sort: \Invoice.dueDate, order: .reverse) private var invoices: [Invoice]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query private var lineItems: [InvoiceLineItem]
    @Query private var payments: [Payment]

    @State private var vm = SettingsViewModel()
    @State private var showResetConfirmation = false

    private let supportedCurrencies = ["USD", "EUR", "GBP", "BRL", "JPY", "CAD", "AUD", "CHF"]

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $themePreference) {
                    ForEach(ThemePreference.allCases) { option in
                        Text(option.label).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Regional") {
                Picker("Currency", selection: $currencyCode) {
                    ForEach(supportedCurrencies, id: \.self) { code in
                        Text(currencyLabel(for: code)).tag(code)
                    }
                }
            }

            Section("Invoice Defaults") {
                Stepper(value: $defaultInvoiceDueDays, in: 1...90) {
                    HStack {
                        Text("Default Due Date")
                        Spacer()
                        Text("\(defaultInvoiceDueDays) days")
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Default Tax")
                        Spacer()
                        Text("\(defaultTaxRate, specifier: "%.1f")%")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $defaultTaxRate, in: 0...30, step: 0.5)
                }
            }

            Section("Behavior") {
                Toggle("Remind for upcoming due invoices", isOn: $remindUpcomingDue)
                Toggle("Show paid invoices on dashboard", isOn: $showPaidOnDashboard)
            }

            Section("Your Information") {
                if clients.isEmpty {
                    Text("No profile information added yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(clients) { client in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(client.name)
                                .font(.headline)

                            if let email = client.email, !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("No email")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            Section("Data Overview") {
                LabeledContent("Clients", value: "\(vm.summary.clients)")
                LabeledContent("Invoices", value: "\(vm.summary.invoices)")
                LabeledContent("Expenses", value: "\(vm.summary.expenses)")
                LabeledContent("Outstanding", value: vm.outstandingTotal.formattedCurrency)
                LabeledContent("Payments Received", value: vm.paymentsTotal.formattedCurrency)
            }

            Section("Privacy") {
                Text(vm.privacyMessage)
                    .font(.subheadline)
                Button("Export Data (Coming Soon)") {}
                    .disabled(true)
            }

            Section("Data Management") {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Text("Delete All App Data")
                }
            }

            Section("General") {
                Text("Version 0.0.1")
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog(
            "Delete all clients, invoices, expenses, and payments?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive) {
                deleteAllData()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: dataChangeToken) { recompute() }
        .onAppear { recompute() }
    }

    private func currencyLabel(for code: String) -> String {
        let locale = Locale.current
        let name = locale.localizedString(forCurrencyCode: code) ?? code
        return "\(name) (\(code))"
    }

    private func recompute() {
        vm.update(
            clients: clients,
            invoices: invoices,
            expenses: expenses,
            lineItems: lineItems,
            payments: payments
        )
    }

    private func deleteAllData() {
        vm.clearAllData(
            modelContext: modelContext,
            clients: clients,
            invoices: invoices,
            expenses: expenses,
            lineItems: lineItems,
            payments: payments
        )
        recompute()
    }

    private var dataChangeToken: [String] {
        clients.map { $0.id.uuidString } +
        invoices.map { "\($0.id.uuidString)|\($0.status.rawValue)" } +
        expenses.map { $0.id.uuidString } +
        lineItems.map { $0.id.uuidString } +
        payments.map { $0.id.uuidString }
    }
}

private enum ThemePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}