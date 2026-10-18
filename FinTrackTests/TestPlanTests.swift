//  Automated tests defined in TEST_PLAN.md
//  ACC-01, TX-01, TX-02, TX-03, TX-04, CAT-01


import XCTest
import CoreData
@testable import FinTrack

@MainActor
final class TestPlanTests: XCTestCase {

    // MARK: - Stack Core Data

    private static let persistence = PersistenceController(inMemory: true)

    private var context: NSManagedObjectContext {
        Self.persistence.container.viewContext
    }

    // MARK: - Workaround: avoid deinit from @MainActor

    private static var keepAlive: [AnyObject] = []

    @discardableResult
    private func keep<T: AnyObject>(_ object: T) -> T {
        Self.keepAlive.append(object)
        return object
    }

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        context.retainsRegisteredObjects = true
        try clearAllData()
    }

    // MARK: - ACC-01

    /// Create account with an initial balance:
    /// persisted with name, icon, initial balance, current balance and creation date.
    func test_ACC01_createAccountWithInitialBalance() throws {
        let accountRepository = keep(AccountRepository(context: context))

        try accountRepository.createAccount(
            name: "Main account",
            initialBalance: 250,
            icon: "building.columns"
        )

        let accounts = try accountRepository.fetchAccounts()
        XCTAssertEqual(accounts.count, 1)

        let account = try XCTUnwrap(accounts.first)
        keep(account)

        XCTAssertNotNil(account.id)
        XCTAssertEqual(account.name, "Main account")
        XCTAssertEqual(account.icon, "building.columns")
        XCTAssertEqual(account.initialBalance, 250, accuracy: 0.001)
        XCTAssertEqual(account.balance, 250, accuracy: 0.001)

        let createdAt = try XCTUnwrap(account.createdAt)
        XCTAssertEqual(createdAt.timeIntervalSinceNow, 0, accuracy: 5)
    }

    // MARK: - TX-01

    /// Create an expense:
    /// transaction is persisted and the account balance decreases by the amount.
    func test_TX01_createExpenseDecreasesBalance() throws {
        let account = try makeAccount(initialBalance: 100)
        let repository = keep(TransactionRepository(context: context))

        try repository.createTransaction(
            amount: 25,
            date: Date(),
            note: "Groceries",
            type: "expense",
            category: nil,
            account: account
        )

        let transactions = try repository.fetchTransactions()
        XCTAssertEqual(transactions.count, 1)

        let transaction = try XCTUnwrap(transactions.first)
        keep(transaction)

        XCTAssertEqual(transaction.amount, 25, accuracy: 0.001)
        XCTAssertEqual(transaction.type, "expense")
        XCTAssertEqual(transaction.note, "Groceries")
        XCTAssertEqual(transaction.account, account)

        XCTAssertEqual(account.balance, 75, accuracy: 0.001)
    }

    // MARK: - TX-02

    /// Create an income:
    /// transaction is persisted and the account balance increases by the amount.
    func test_TX02_createIncomeIncreasesBalance() throws {
        let account = try makeAccount(initialBalance: 100)
        let repository = keep(TransactionRepository(context: context))

        try repository.createTransaction(
            amount: 50,
            date: Date(),
            note: "Payroll",
            type: "income",
            category: nil,
            account: account
        )

        let transactions = try repository.fetchTransactions()
        XCTAssertEqual(transactions.count, 1)

        let transaction = try XCTUnwrap(transactions.first)
        keep(transaction)

        XCTAssertEqual(transaction.amount, 50, accuracy: 0.001)
        XCTAssertEqual(transaction.type, "income")
        XCTAssertEqual(transaction.account, account)

        XCTAssertEqual(account.balance, 150, accuracy: 0.001)
    }

    // MARK: - TX-03

    /// Update a transaction:
    /// the previous balance effect is reverted and the new one applied exactly once.
    func test_TX03_updateTransactionAppliesNewEffectOnce() throws {
        let account = try makeAccount(initialBalance: 100)
        let repository = keep(TransactionRepository(context: context))

        // Expense to 20 -> 100 - 20 = 80
        try repository.createTransaction(
            amount: 20,
            date: Date(),
            note: "Purchase",
            type: "expense",
            category: nil,
            account: account
        )

        let transaction = try XCTUnwrap(
            try repository.fetchTransactions().first
        )
        keep(transaction)

        XCTAssertEqual(account.balance, 80, accuracy: 0.001)

        // It becomes an income of 30:
        // reverses the expenditure (80 + 20 = 100) and applies the income (100 + 30 = 130))
        try repository.updateTransaction(
            transaction,
            amount: 30,
            date: Date(),
            note: "Refund",
            type: "income",
            category: nil,
            account: account
        )

        XCTAssertEqual(account.balance, 130, accuracy: 0.001)
        XCTAssertEqual(transaction.amount, 30, accuracy: 0.001)
        XCTAssertEqual(transaction.type, "income")
        XCTAssertEqual(transaction.note, "Refund")
        XCTAssertEqual(try repository.fetchTransactions().count, 1)
    }

    // MARK: - TX-04

    /// Delete a transaction:
    /// the transaction is removed and its balance effect is reverted.
    func test_TX04_deleteTransactionRevertsBalance() throws {
        let account = try makeAccount(initialBalance: 100)
        let repository = keep(TransactionRepository(context: context))

        try repository.createTransaction(
            amount: 40,
            date: Date(),
            note: "Purchase",
            type: "expense",
            category: nil,
            account: account
        )

        let transaction = try XCTUnwrap(
            try repository.fetchTransactions().first
        )
        // It is saved BEFORE it is deleted: once removed from the context,
        // The context ceases to retain it, and it would be released upon completion of the test.
        keep(transaction)

        XCTAssertEqual(account.balance, 60, accuracy: 0.001)

        try repository.deleteTransaction(transaction)

        XCTAssertTrue(try repository.fetchTransactions().isEmpty)
        XCTAssertEqual(account.balance, 100, accuracy: 0.001)
    }

    // MARK: - CAT-01

    /// Run the category seeder twice:
    /// the expected English categories exist once each.
    func test_CAT01_seedingTwiceDoesNotDuplicateCategories() throws {
        AppSeeder.seed(context: context)
        AppSeeder.seed(context: context)

        let expectedNames = [
            "Feeding",
            "Transport",
            "Leisure",
            "Shopping",
            "Subscriptions",
            "House",
            "Health",
            "Salary",
            "Other"
        ]

        let categories = try context.fetch(
            NSFetchRequest<FinTrack.Category>(entityName: "Category")
        )
        categories.forEach { keep($0) }

        for name in expectedNames {
            let count = categories.filter { $0.name == name }.count
            XCTAssertEqual(count, 1, "La categoría \(name) debería existir una sola vez")
        }

        XCTAssertEqual(categories.count, expectedNames.count)
    }

    // MARK: - Helpers

    /// Creates an account using the actual repository and returns it.
    private func makeAccount(initialBalance: Double) throws -> Account {
        let accountRepository = keep(AccountRepository(context: context))

        try accountRepository.createAccount(
            name: "Test account",
            initialBalance: initialBalance,
            icon: "building.columns"
        )

        let account = try XCTUnwrap(
            try accountRepository.fetchAccounts().first
        )
        return keep(account)
    }

    /// Clear all entities so that each test starts from scratch.
    /// Objects are saved before being deleted so that they are not released.
    private func clearAllData() throws {
        for entityName in ["Transaction", "Budget", "Account", "Category"] {
            let objects = try context.fetch(
                NSFetchRequest<NSManagedObject>(entityName: entityName)
            )
            objects.forEach { keep($0) }
            objects.forEach { context.delete($0) }
        }

        if context.hasChanges {
            try context.save()
        }
    }
}
