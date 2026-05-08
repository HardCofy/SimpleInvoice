import SwiftData
import Foundation

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case software
    case travel
    case meals
    case office
    case marketing
    case professionalServices
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .software: return "Software"
        case .travel: return "Travel"
        case .meals: return "Meals"
        case .office: return "Office"
        case .marketing: return "Marketing"
        case .professionalServices: return "Professional Services"
        case .other: return "Other"
        }
    }
}

@Model
final class Expense {

    var id: UUID

    var title: String
    var category: ExpenseCategory
    var amount: Double
    var date: Date

    init(
        title: String,
        category: ExpenseCategory,
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