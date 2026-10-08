import Combine
import CoreData
import Foundation

@MainActor
final class TransactionsViewModel: ObservableObject {

    @Published var transactions: [Transaction] = []
    @Published var errorMessage: String?
    @Published var refreshID = UUID()

    private let repository: TransactionRepository

    init(context: NSManagedObjectContext) {
        self.repository = TransactionRepository(
            context: context
        )
    }

    // MARK: - Fetch

    func fetchTransactions() {
            do {
                transactions = try repository.fetchTransactions()
                refreshID = UUID()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    
    // MARK: - Create

    func createTransaction(
        amount: Double,
        date: Date,
        note: String,
        type: String,
        category: Category?,
        account: Account?
    ) {

        do {

            try repository.createTransaction(
                amount: amount,
                date: date,
                note: note,
                type: type,
                category: category,
                account: account
            )

            fetchTransactions()

        } catch {

            errorMessage = error.localizedDescription
        }
    }
    
    //MARK: - Update
    
    func updateTransaction(
        _ transaction: Transaction,
        amount: Double,
        date: Date,
        note: String,
        type: String,
        category: Category?,
        account: Account?
    ) {

        do {

            try repository.updateTransaction(
                transaction,
                amount: amount,
                date: date,
                note: note,
                type: type,
                category: category,
                account: account
            )

            fetchTransactions()

        } catch {

            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteTransaction(
        _ transaction: Transaction
    ) {

        do {

            try repository.deleteTransaction(
                transaction
            )

            fetchTransactions()

        } catch {

            errorMessage = error.localizedDescription
        }
    }
}
