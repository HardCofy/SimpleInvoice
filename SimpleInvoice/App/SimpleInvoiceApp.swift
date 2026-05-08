//
//  SimpleInvoiceApp.swift
//  SimpleInvoice
//
//  Created by João Gomes Santos on 05/05/2026.
//

import SwiftUI
import SwiftData

@main
struct SimpleInvoiceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Client.self,
            Invoice.self,
            InvoiceLineItem.self,
            Expense.self,
            Payment.self
        ])
    }
}
