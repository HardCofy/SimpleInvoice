import SwiftUI
import SwiftData

struct InvoicesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Invoice.dueDate, order: .reverse) private var invoices: [Invoice]
    @Query private var lineItems: [InvoiceLineItem]
    @Query private var payments: [Payment]

    @State private var vm = InvoicesViewModel()
    @State private var showingCreateInvoice = false

    var body: some View {
        List {
            // Filter picker
            Picker("Filter", selection: $vm.filter) {
                ForEach(InvoiceStatusFilter.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)

            ForEach(vm.displayed) { invoice in
                NavigationLink {
                    InvoiceFormView(invoice: invoice)
                } label: {
                    invoiceRow(invoice)
                }
                .swipeActions(edge: .leading) {
                    if vm.canMarkPaid(invoice, lineItems: lineItems, payments: payments) {
                        Button("Mark Paid") {
                            vm.markPaid(invoice, in: modelContext)
                            recompute()
                        }
                        .tint(.green)
                    }
                }
            }
            .onDelete(perform: deleteInvoices)
        }
        .searchable(text: $vm.searchQuery)
        .onChange(of: invoiceChangeToken)  { recompute() }
        .onChange(of: lineItemChangeToken) { recompute() }
        .onChange(of: paymentChangeToken)  { recompute() }
        .onChange(of: vm.filter)     { recompute() }
        .onChange(of: vm.searchQuery){ recompute() }
        .onAppear { recompute() }
        .navigationTitle("Invoices")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateInvoice = true
                } label: {
                    Label("New Invoice", systemImage: "plus")
                }
                .accessibilityIdentifier("invoices.new")
            }
        }
        .sheet(isPresented: $showingCreateInvoice) {
            NavigationStack {
                InvoiceFormView()
            }
        }
    }

    private func recompute() {
        vm.update(invoices: invoices, lineItems: lineItems, payments: payments)
    }

    private func invoiceRow(_ invoice: Invoice) -> some View {
        let total = InvoiceCalculator.total(for: invoice, lineItems: lineItems)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(invoice.client?.name ?? "No Client").font(.headline)
                Spacer()
                Text(total.formattedCurrency).font(.headline)
            }
            HStack {
                Text("Due \(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(invoice.status == .paid ? "Paid" : (invoice.status == .overdue ? "Overdue" : "Open"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(invoice.status == .paid ? .green : (invoice.status == .overdue ? .red : .orange))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background((invoice.status == .paid ? Color.green : (invoice.status == .overdue ? Color.red : Color.orange)).opacity(0.15))
                    .clipShape(Capsule())
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }

    private func deleteInvoices(at offsets: IndexSet) {
        for index in offsets {
            let invoice = vm.displayed[index]

            for item in lineItems where item.invoice?.id == invoice.id {
                modelContext.delete(item)
            }

            for payment in payments where payment.invoice?.id == invoice.id {
                modelContext.delete(payment)
            }

            modelContext.delete(invoice)
        }

        try? modelContext.save()
        recompute()
    }

    private var invoiceChangeToken: [String] {
        invoices.map { "\($0.id.uuidString)|\($0.status.rawValue)|\($0.dueDate.timeIntervalSince1970)" }
    }

    private var lineItemChangeToken: [String] {
        lineItems.map { "\($0.id.uuidString)|\($0.quantity)|\($0.unitPrice)" }
    }

    private var paymentChangeToken: [String] {
        payments.map { "\($0.id.uuidString)|\($0.amount)|\($0.date.timeIntervalSince1970)" }
    }
}

private struct InvoiceFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Client.name) private var clients: [Client]
    @Query private var lineItems: [InvoiceLineItem]

    private let invoice: Invoice?

    @State private var selectedClientID: UUID?
    @State private var newClientName = ""
    @State private var dueDate = Date.now
    @State private var notes = ""
    @State private var lineItemTitle = ""
    @State private var quantity = 1
    @State private var unitPrice = 0.0
    @State private var vm = InvoicesViewModel()

    @AppStorage("app.defaultInvoiceDueDays") private var defaultInvoiceDueDays = 14
    @AppStorage("app.defaultTaxRate") private var defaultTaxRate = 0.0

    init(invoice: Invoice? = nil) {
        self.invoice = invoice
    }

    var body: some View {
        Form {
            Section("Client") {
                Picker("Existing Client", selection: $selectedClientID) {
                    Text("Create New Client").tag(UUID?.none)
                    ForEach(clients) { client in
                        Text(client.name).tag(Optional(client.id))
                    }
                }
                .accessibilityIdentifier("invoice.clientPicker")

                if selectedClientID == nil {
                    TextField("Client Name", text: $newClientName)
                        .accessibilityIdentifier("invoice.clientName")
                }
            }

            Section("Invoice Details") {
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
                    .accessibilityIdentifier("invoice.notes")
            }

            Section("Line Item") {
                TextField("Description", text: $lineItemTitle)
                    .accessibilityIdentifier("invoice.lineItemTitle")

                Stepper(value: $quantity, in: 1...999) {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Text("\(quantity)")
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Text("Unit Price")
                    Spacer()
                    TextField("0.00", value: $unitPrice, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 120)
                        .accessibilityIdentifier("invoice.unitPrice")
                }

                HStack {
                    Text("Total")
                    Spacer()
                    Text((Double(quantity) * unitPrice).formattedCurrency)
                        .fontWeight(.semibold)
                }
            }
        }
        .navigationTitle(invoice == nil ? "New Invoice" : "Edit Invoice")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { save() }
                    .disabled(!canSave)
                    .accessibilityIdentifier("invoice.save")
            }
        }
        .onAppear(perform: loadInitialValues)
    }

    private var canSave: Bool {
        vm.isValidInvoiceInput(
            selectedClientID: selectedClientID,
            newClientName: newClientName,
            lineItemTitle: lineItemTitle,
            unitPrice: unitPrice,
            dueDate: dueDate
        )
    }

    private func loadInitialValues() {
        guard let invoice else {
            dueDate = Calendar.current.date(byAdding: .day, value: defaultInvoiceDueDays, to: .now) ?? .now
            return
        }

        selectedClientID = invoice.client?.id
        dueDate = invoice.dueDate
        notes = invoice.notes ?? ""

        if let existingItem = lineItems.first(where: { $0.invoice?.id == invoice.id }) {
            lineItemTitle = existingItem.title
            quantity = max(1, existingItem.quantity)
            unitPrice = existingItem.unitPrice
        }
    }

    private func save() {
        let client = resolveClient()
        let workingInvoice: Invoice

        if let invoice {
            workingInvoice = invoice
            workingInvoice.client = client
            workingInvoice.dueDate = dueDate
            workingInvoice.notes = normalizedNotes
            if workingInvoice.status == .paid {
                workingInvoice.status = .sent
            }
        } else {
            let created = Invoice(
                client: client,
                issuedDate: .now,
                dueDate: dueDate,
                notes: normalizedNotes,
                status: .sent,
                taxRate: defaultTaxRate
            )
            modelContext.insert(created)
            workingInvoice = created
        }

        workingInvoice.refreshOverdueStatus()
        upsertLineItem(for: workingInvoice)

        try? modelContext.save()
        dismiss()
    }

    private func resolveClient() -> Client {
        if let selectedClientID, let existingClient = clients.first(where: { $0.id == selectedClientID }) {
            return existingClient
        }

        let newClient = Client(name: newClientName.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(newClient)
        return newClient
    }

    private func upsertLineItem(for invoice: Invoice) {
        if let existingItem = lineItems.first(where: { $0.invoice?.id == invoice.id }) {
            existingItem.title = lineItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            existingItem.quantity = quantity
            existingItem.unitPrice = unitPrice
            return
        }

        let item = InvoiceLineItem(
            invoice: invoice,
            title: lineItemTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity,
            unitPrice: unitPrice
        )
        modelContext.insert(item)
    }

    private var normalizedNotes: String? {
        let value = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}