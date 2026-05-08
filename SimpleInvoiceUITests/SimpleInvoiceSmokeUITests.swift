import XCTest

final class SimpleInvoiceSmokeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCreateInvoiceAndExpenseFlows() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Invoices"].tap()
        app.buttons["invoices.new"].tap()

        let clientName = app.textFields["invoice.clientName"]
        XCTAssertTrue(clientName.waitForExistence(timeout: 2))
        clientName.tap()
        clientName.typeText("Acme")

        let lineTitle = app.textFields["invoice.lineItemTitle"]
        lineTitle.tap()
        lineTitle.typeText("Website Build")

        let unitPrice = app.textFields["invoice.unitPrice"]
        unitPrice.tap()
        unitPrice.typeText("500")

        app.buttons["invoice.save"].tap()
        XCTAssertTrue(app.staticTexts["Acme"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Expenses"].tap()
        app.buttons["expenses.new"].tap()

        let expenseTitle = app.textFields["expense.title"]
        XCTAssertTrue(expenseTitle.waitForExistence(timeout: 2))
        expenseTitle.tap()
        expenseTitle.typeText("Figma")

        let amount = app.textFields["expense.amount"]
        amount.tap()
        amount.typeText("25")

        app.buttons["expense.save"].tap()
        XCTAssertTrue(app.staticTexts["Figma"].waitForExistence(timeout: 2))
    }
}
