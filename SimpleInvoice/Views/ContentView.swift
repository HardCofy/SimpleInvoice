//
//  ContentView.swift
//  SimpleInvoice
//
//  Created by João Gomes Santos on 05/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.pie")
            }

            NavigationStack {
                Text("Invoices coming soon")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Invoices")
            }
            .tabItem {
                Label("Invoices", systemImage: "doc.text")
            }

            NavigationStack {
                Text("Expenses coming soon")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Expenses")
            }
            .tabItem {
                Label("Expenses", systemImage: "creditcard")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [
                Client.self,
                Invoice.self,
                InvoiceLineItem.self,
                Expense.self,
                Payment.self
            ],
            inMemory: true
        )
}
