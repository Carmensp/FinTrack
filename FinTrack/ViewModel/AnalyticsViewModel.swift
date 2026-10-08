import Combine
import CoreData
import Foundation

struct AnalyticsChartPoint: Identifiable {
    let id = UUID()
    let label: String
    let income: Double
    let expenses: Double
}

struct CategoryChartPoint: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

struct SavingsChartPoint: Identifiable {
    let id = UUID()
    let label: String
    let savings: Double
}

@MainActor
final class AnalyticsViewModel: ObservableObject {

    @Published var totalIncome: Double = 0
    @Published var totalExpenses: Double = 0
    @Published var chartPoints: [AnalyticsChartPoint] = []
    @Published var categoryPoints: [CategoryChartPoint] = []
    @Published var savingsPoints: [SavingsChartPoint] = []

    private let repository: TransactionRepository

    init(context: NSManagedObjectContext) {
        self.repository = TransactionRepository(
            context: context
        )
    }

    var savings: Double {
        totalIncome - totalExpenses
    }

    func loadAnalytics(
        period: DashboardPeriod
    ) {
        do {
            let transactions =
                try repository.fetchTransactions()

            let calendar = Calendar.current
            let today = Date()

            let filteredTransactions =
                transactions.filter { transaction in

                    guard let date = transaction.date else {
                        return false
                    }

                    switch period {
                    case .week:
                        return calendar.isDate(
                            date,
                            equalTo: today,
                            toGranularity: .weekOfYear
                        )

                    case .month:
                        return calendar.isDate(
                            date,
                            equalTo: today,
                            toGranularity: .month
                        )

                    case .year:
                        return calendar.isDate(
                            date,
                            equalTo: today,
                            toGranularity: .year
                        )

                    case .total:
                        return true
                    }
                }

            totalIncome = filteredTransactions
                .filter { $0.type == "income" }
                .reduce(0) {
                    $0 + $1.amount
                }

            totalExpenses = filteredTransactions
                .filter { $0.type == "expense" }
                .reduce(0) {
                    $0 + $1.amount
                }

            chartPoints = buildChartPoints(
                from: filteredTransactions,
                period: period
            )
            
            categoryPoints = buildCategoryPoints(
                from: filteredTransactions
            )
            
            savingsPoints = buildSavingsPoints(
                from: filteredTransactions
            )

        } catch {
            print(
                "Error loading analytics: \(error)"
            )
        }
    }

    // MARK: - Chart data

    private func buildChartPoints(
        from transactions: [Transaction],
        period: DashboardPeriod
    ) -> [AnalyticsChartPoint] {

        let calendar = Calendar.current
        let today = Date()

        switch period {

        case .week:
            return buildDailyPoints(
                transactions: transactions,
                calendar: calendar,
                today: today
            )

        case .month:
            return buildWeeklyPoints(
                transactions: transactions,
                calendar: calendar,
                today: today
            )

        case .year:
            return buildMonthlyPoints(
                transactions: transactions,
                calendar: calendar,
                today: today
            )

        case .total:
            return buildMonthlyPoints(
                transactions: transactions,
                calendar: calendar,
                today: today
            )
        }
    }

    // MARK: - Week

    private func buildDailyPoints(
        transactions: [Transaction],
        calendar: Calendar,
        today: Date
    ) -> [AnalyticsChartPoint] {

        (0..<7).reversed().compactMap { offset in

            guard let date = calendar.date(
                byAdding: .day,
                value: -offset,
                to: today
            ) else {
                return nil
            }

            let dayTransactions = transactions.filter { transaction in
                guard let transactionDate = transaction.date else {
                    return false
                }

                return calendar.isDate(
                    transactionDate,
                    inSameDayAs: date
                )
            }

            let income = dayTransactions
                .filter { $0.type == "income" }
                .reduce(0) {
                    $0 + $1.amount
                }

            let expenses = dayTransactions
                .filter { $0.type == "expense" }
                .reduce(0) {
                    $0 + $1.amount
                }

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_ES")
            formatter.dateFormat = "EEE"

            return AnalyticsChartPoint(
                label: formatter.string(from: date),
                income: income,
                expenses: expenses
            )
        }
    }

    // MARK: - Month

    private func buildWeeklyPoints(
        transactions: [Transaction],
        calendar: Calendar,
        today: Date
    ) -> [AnalyticsChartPoint] {

        guard let startOfMonth = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: today
            )
        ) else {
            return []
        }

        return (0..<5).compactMap { weekIndex in

            guard let weekStart = calendar.date(
                byAdding: .weekOfYear,
                value: weekIndex,
                to: startOfMonth
            ) else {
                return nil
            }

            let weekEnd = calendar.date(
                byAdding: .day,
                value: 6,
                to: weekStart
            ) ?? weekStart

            let weekTransactions = transactions.filter { transaction in
                guard let date = transaction.date else {
                    return false
                }

                return date >= weekStart && date <= weekEnd
            }

            let income = weekTransactions
                .filter { $0.type == "income" }
                .reduce(0) {
                    $0 + $1.amount
                }

            let expenses = weekTransactions
                .filter { $0.type == "expense" }
                .reduce(0) {
                    $0 + $1.amount
                }

            return AnalyticsChartPoint(
                label: "Sem. \(weekIndex + 1)",
                income: income,
                expenses: expenses
            )
        }
    }

    // MARK: - Year / Total

    private func buildMonthlyPoints(
        transactions: [Transaction],
        calendar: Calendar,
        today: Date
    ) -> [AnalyticsChartPoint] {

        let months: [Date]

        if transactions.isEmpty {
            months = []
        } else {
            let dates = transactions.compactMap {
                $0.date
            }

            guard
                let earliestDate = dates.min(),
                let startMonth = calendar.date(
                    from: calendar.dateComponents(
                        [.year, .month],
                        from: earliestDate
                    )
                ),
                let endMonth = calendar.date(
                    from: calendar.dateComponents(
                        [.year, .month],
                        from: today
                    )
                )
            else {
                return []
            }

            var result: [Date] = []
            var current = startMonth

            while current <= endMonth {
                result.append(current)

                guard let next = calendar.date(
                    byAdding: .month,
                    value: 1,
                    to: current
                ) else {
                    break
                }

                current = next
            }

            months = result
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "MMM"

        return months.map { month in

            let monthTransactions = transactions.filter { transaction in
                guard let date = transaction.date else {
                    return false
                }

                return calendar.isDate(
                    date,
                    equalTo: month,
                    toGranularity: .month
                )
            }

            let income = monthTransactions
                .filter { $0.type == "income" }
                .reduce(0) {
                    $0 + $1.amount
                }

            let expenses = monthTransactions
                .filter { $0.type == "expense" }
                .reduce(0) {
                    $0 + $1.amount
                }

            return AnalyticsChartPoint(
                label: formatter.string(from: month),
                income: income,
                expenses: expenses
            )
        }
    }
    
    private func buildCategoryPoints(
        from transactions: [Transaction]
    ) -> [CategoryChartPoint] {

        let expenses = transactions.filter {
            $0.type == "expense"
        }

        let grouped = Dictionary(
            grouping: expenses,
            by: { $0.category?.name ?? "Otros" }
        )

        return grouped
            .map { category, transactions in
                let total = transactions.reduce(0) {
                    $0 + $1.amount
                }

                return CategoryChartPoint(
                    category: category,
                    amount: total
                )
            }
            .sorted {
                $0.amount > $1.amount
            }
    }
    
    private func buildSavingsPoints(
        from transactions: [Transaction]
    ) -> [SavingsChartPoint] {

        let sortedTransactions = transactions.sorted {
            ($0.date ?? .distantPast) < ($1.date ?? .distantPast)
        }

        var accumulatedSavings = 0.0

        return sortedTransactions.map { transaction in
            if transaction.type == "income" {
                accumulatedSavings += transaction.amount
            } else if transaction.type == "expense" {
                accumulatedSavings -= transaction.amount
            }

            return SavingsChartPoint(
                label: transaction.date?.formatted(
                    .dateTime.day().month(.abbreviated)
                ) ?? "",
                savings: accumulatedSavings
            )
        }
    }
}
