import Combine
import CoreData
import Foundation

@MainActor
final class BudgetsViewModel: ObservableObject {

    @Published var budgets: [Budget] = []
    @Published var errorMessage: String?
    @Published var refreshID = UUID()

    private let budgetRepository: BudgetRepository
    private let transactionRepository: TransactionRepository

    init(context: NSManagedObjectContext) {
        self.budgetRepository = BudgetRepository(
            context: context
        )

        self.transactionRepository = TransactionRepository(
            context: context
        )
    }

    // MARK: - Load

    func fetchBudgets() {
            do {
                budgets = try budgetRepository.fetchBudgets()
                refreshID = UUID()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    
    func spent(for budget: Budget) -> Double {

        guard let category = budget.category else {
            return 0
        }

        do {
            let transactions =
                try transactionRepository.fetchTransactions()

            let calendar = Calendar.current
            let budgetMonth = budget.month ?? Date()

            return transactions
                .filter { transaction in

                    guard
                        transaction.type == "expense",
                        transaction.category == category,
                        let transactionDate = transaction.date
                    else {
                        return false
                    }

                    return calendar.isDate(
                        transactionDate,
                        equalTo: budgetMonth,
                        toGranularity: .month
                    )
                }
                .reduce(0) {
                    $0 + $1.amount
                }

        } catch {
            errorMessage = error.localizedDescription
            return 0
        }
    }

    // MARK: - Create

    func createBudget(
        amount: Double,
        month: Date,
        category: Category?
    ) {
        do {
            try budgetRepository.createBudget(
                amount: amount,
                month: month,
                category: category
            )

            fetchBudgets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update

    func updateBudget(
        _ budget: Budget,
        amount: Double,
        month: Date,
        category: Category?
    ) {
        do {
            try budgetRepository.updateBudget(
                budget,
                amount: amount,
                month: month,
                category: category
            )

            fetchBudgets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteBudget(
        _ budget: Budget
    ) {
        do {
            try budgetRepository.deleteBudget(budget)

            fetchBudgets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
