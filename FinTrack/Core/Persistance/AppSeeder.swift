
import CoreData

struct AppSeeder {

    static func seed(context: NSManagedObjectContext) {

        seedCategories(context: context)
        seedAccounts(context: context)

        do {
            try context.save()
        } catch {
            print("Error seeding data: \(error)")
        }
    }

    private static func seedCategories(
        context: NSManagedObjectContext
    ) {

        let request = NSFetchRequest<Category>(
            entityName: "Category"
        )

        let existingCategories = (
            try? context.fetch(request)
        ) ?? []

        guard existingCategories.isEmpty else {
            return
        }

        let categories = [
            ("Alimentación", "cart"),
            ("Transporte", "car"),
            ("Ocio", "gamecontroller"),
            ("Compras", "bag"),
            ("Suscripciones", "repeat"),
            ("Vivienda", "house"),
            ("Salud", "heart"),
            ("Salary", "eurosign"),
            ("Otros", "ellipsis.circle")
        ]

        for (name, icon) in categories {

            let category = Category(context: context)

            category.id = UUID()
            category.name = name
            category.icon = icon
        }
    }

    private static func seedAccounts(
        context: NSManagedObjectContext
    ) {

        let request = NSFetchRequest<Account>(
            entityName: "Account"
        )

        let existingAccounts = (
            try? context.fetch(request)
        ) ?? []

        guard existingAccounts.isEmpty else {
            return
        }

        let accounts = [
            ("Santander", "building.columns"),
            ("Ahorros", "banknote"),
            ("Wise", "creditcard")
        ]

        for (name, icon) in accounts {

            let account = Account(context: context)

            account.id = UUID()
            account.name = name
            account.icon = icon
            account.balance = 0
        }
    }
}
