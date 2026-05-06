import SwiftData
import Foundation

@Model
final class Expense {

    var id: UUID

    var title: String
    var category: String
    var amount: Double
    var date: Date

    init(
        title: String,
        category: String,
        amount: Double,
        date: Date = .now
    ) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.amount = amount
        self.date = date
    }

}