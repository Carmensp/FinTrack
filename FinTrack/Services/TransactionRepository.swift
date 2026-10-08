import CoreData

final class TransactionRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Transactions

    func createTransaction(
        amount: Double,
        date: Date,
        note: String,
        type: String,
        category: Category?,
        account: Account?
    ) throws {

        let transaction = Transaction(context: context)

        transaction.id = UUID()
        transaction.amount = amount
        transaction.date = date
        transaction.note = note
        transaction.type = type

        transaction.category = category
        transaction.account = account

        // Update account balance
        if let account = account {

            if type == "income" {
                account.balance += amount
            } else if type == "expense" {
                account.balance -= amount
            }
        }

        try context.save()
    }

    func fetchTransactions() throws -> [Transaction] {

        let request = NSFetchRequest<Transaction>(
            entityName: "Transaction"
        )

        request.sortDescriptors = [
            NSSortDescriptor(
                key: "date",
                ascending: false
            )
        ]

        return try context.fetch(request)
    }

    func fetchTransaction(
        with id: UUID
    ) throws -> Transaction? {

        let request = NSFetchRequest<Transaction>(
            entityName: "Transaction"
        )

        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )

        request.fetchLimit = 1

        return try context.fetch(request).first
    }

    func updateTransaction(
        _ transaction: Transaction,
        amount: Double,
        date: Date,
        note: String,
        type: String,
        category: Category?,
        account: Account?
    ) throws {

        // 1. Revert the old transaction
        if let oldAccount = transaction.account {

            if transaction.type == "income" {
                oldAccount.balance -= transaction.amount
            } else if transaction.type == "expense" {
                oldAccount.balance += transaction.amount
            }
        }

        // 2. Update transaction
        transaction.amount = amount
        transaction.date = date
        transaction.note = note
        transaction.type = type
        transaction.category = category
        transaction.account = account

        // 3. Apply the new transaction
        if let newAccount = account {

            if type == "income" {
                newAccount.balance += amount
            } else if type == "expense" {
                newAccount.balance -= amount
            }
        }

        try context.save()
    }

    func deleteTransaction(
        _ transaction: Transaction
    ) throws {

        // Revert the account balance
        if let account = transaction.account {

            if transaction.type == "income" {
                account.balance -= transaction.amount
            } else if transaction.type == "expense" {
                account.balance += transaction.amount
            }
        }

        context.delete(transaction)

        try context.save()
    }

    // MARK: - Accounts

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
}
