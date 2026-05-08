//
//  ContentView.swift
//  SimpleInvoice
//
//  Created by João Gomes Santos on 05/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("app.themePreference") private var themePreference = "system"

    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.pie")
            }

            NavigationStack {
                InvoicesView()
            }
            .tabItem {
                Label("Invoices", systemImage: "doc.text")
            }

            NavigationStack {
                ExpensesView()
            }
            .tabItem {
                Label("Expenses", systemImage: "creditcard")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .preferredColorScheme(selectedColorScheme)
    }

    private var selectedColorScheme: ColorScheme? {
        switch themePreference {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
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
