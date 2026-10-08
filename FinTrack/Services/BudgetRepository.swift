import CoreData

final class BudgetRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Create

    func createBudget(
        amount: Double,
        month: Date,
        category: Category?
    ) throws {

        let budget = Budget(context: context)

        budget.id = UUID()
        budget.amount = amount
        budget.month = month
        budget.category = category

        try context.save()
    }

    // MARK: - Read

    func fetchBudgets() throws -> [Budget] {

        let request = NSFetchRequest<Budget>(
            entityName: "Budget"
        )

        request.sortDescriptors = [
            NSSortDescriptor(
                key: "month",
                ascending: false
            )
        ]

        return try context.fetch(request)
    }

    // MARK: - Update

    func updateBudget(
        _ budget: Budget,
        amount: Double,
        month: Date,
        category: Category?
    ) throws {

        budget.amount = amount
        budget.month = month
        budget.category = category

        try context.save()
    }

    // MARK: - Delete

    func deleteBudget(
        _ budget: Budget
    ) throws {

        context.delete(budget)

        try context.save()
    }
}
