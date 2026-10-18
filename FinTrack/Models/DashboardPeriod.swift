import Foundation

enum DashboardPeriod {
    case week
    case month
    case year
    case total
}

extension DashboardPeriod {
    var description: String {
        switch self {
        case .week:
            return "this week"
        case .month:
            return "this month"
        case .year:
            return "this year"
        case .total:
            return "in total"
        }
    }
}

