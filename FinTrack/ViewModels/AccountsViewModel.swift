import Combine
import CoreData
import Foundation

@MainActor
final class AccountsViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var errorMessage: String?

    private let repository: AccountRepository

    init(context: NSManagedObjectContext) {
        self.repository = AccountRepository(
            context: context
        )
    }

    // MARK: - Fetch

    func fetchAccounts() {
        do {
            accounts = try repository.fetchAccounts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create

    func createAccount(
        name: String,
        initialBalance: Double,
        icon: String
    ) {
        do {
            try repository.createAccount(
                name: name,
                initialBalance: initialBalance,
                icon: icon
            )

            fetchAccounts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update

    func updateAccount(
        _ account: Account,
        name: String,
        balance: Double,
        icon: String
    ) {
        do {
            try repository.updateAccount(
                account,
                name: name,
                balance: balance,
                icon: icon
            )
            fetchAccounts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteAccount(
        _ account: Account
    ) {
        do {
            try repository.deleteAccount(account)

            fetchAccounts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
