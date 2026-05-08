import XCTest
@testable import SimpleInvoice

final class InvoiceCalculatorTests: XCTestCase {
    func testSubtotalTaxTotalPaidAndOutstanding() {
        let invoice = Invoice(dueDate: .now, taxRate: 10)
        let itemA = InvoiceLineItem(invoice: invoice, title: "Design", quantity: 2, unitPrice: 100)
        let itemB = InvoiceLineItem(invoice: invoice, title: "Development", quantity: 1, unitPrice: 50)
        let payment = Payment(invoice: invoice, amount: 120)

        let lineItems = [itemA, itemB]
        let payments = [payment]

        let subtotal = InvoiceCalculator.subtotal(for: invoice, lineItems: lineItems)
        let total = InvoiceCalculator.total(for: invoice, lineItems: lineItems)
        let paid = InvoiceCalculator.paid(for: invoice, payments: payments)
        let outstanding = InvoiceCalculator.outstanding(for: invoice, lineItems: lineItems, payments: payments)

        XCTAssertEqual(subtotal, 250, accuracy: 0.0001)
        XCTAssertEqual(total, 275, accuracy: 0.0001)
        XCTAssertEqual(paid, 120, accuracy: 0.0001)
        XCTAssertEqual(outstanding, 155, accuracy: 0.0001)
    }

    func testOutstandingNeverReturnsNegative() {
        let invoice = Invoice(dueDate: .now, taxRate: 0)
        let item = InvoiceLineItem(invoice: invoice, title: "Consulting", quantity: 1, unitPrice: 100)
        let payment = Payment(invoice: invoice, amount: 150)

        let outstanding = InvoiceCalculator.outstanding(
            for: invoice,
            lineItems: [item],
            payments: [payment]
        )

        XCTAssertEqual(outstanding, 0, accuracy: 0.0001)
    }
}
