import Foundation

extension Double {
    var formattedCurrency: String {
        let configuredCode = UserDefaults.standard.string(forKey: "app.currencyCode")
        let currencyCode = configuredCode ?? Locale.current.currency?.identifier ?? "USD"
        return self.formatted(.currency(code: currencyCode))
    }
}
