import CoreData

final class AccountRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch

    func fetchAccounts() throws -> [Account] {
        let request = NSFetchRequest<Account>(
            entityName: "Account"
        )

        request.sortDescriptors = [
            NSSortDescriptor(
                key: "name",
                ascending: true
            )
        ]

        return try context.fetch(request)
    }

    // MARK: - Create

    func createAccount(
        name: String,
        initialBalance: Double,
        icon: String
    ) throws {
        let account = Account(context: context)

        account.id = UUID()
        account.name = name
        account.initialBalance = initialBalance
        account.balance = initialBalance
        account.icon = icon

        try context.save()
    }

    // MARK: - Update

    func updateAccount(
        _ account: Account,
        name: String,
        balance: Double,
        icon: String
    ) throws {
        account.name = name
        account.balance = balance
        account.icon = icon

        try context.save()
    }

    // MARK: - Delete

    func deleteAccount(
        _ account: Account
    ) throws {
        context.delete(account)

        try context.save()
    }
}
