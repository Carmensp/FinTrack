
import CoreData

struct AppSeeder {

    static func seed(context: NSManagedObjectContext) {

        seedCategories(context: context)
        //seedAccounts(context: context)

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

        do {
            let existingCategories = try context.fetch(request)

            let spanishNames: Set<String> = [
                "Alimentación",
                "Transporte",
                "Ocio",
                "Compras",
                "Suscripciones",
                "Vivienda",
                "Salud",
                "Salario",
                "Otros",
                "Suscriptions"
            ]

            // Eliminar las categorías antiguas en español
            for category in existingCategories {
                if let name = category.name,
                   spanishNames.contains(name) {
                    context.delete(category)
                }
            }

            let remainingNames = Set(
                existingCategories
                    .filter { !$0.isDeleted }
                    .compactMap { $0.name?.lowercased() }
            )

            let categories = [
                ("Feeding", "cart"),
                ("Transport", "car"),
                ("Leisure", "gamecontroller"),
                ("Shopping", "bag"),
                ("Subscriptions", "repeat"),
                ("House", "house"),
                ("Health", "heart"),
                ("Salary", "eurosign"),
                ("Other", "ellipsis.circle")
            ]

            // Crear únicamente las categorías que falten
            for (name, icon) in categories {
                guard !remainingNames.contains(name.lowercased()) else {
                    continue
                }

                let category = Category(context: context)
                category.id = UUID()
                category.name = name
                category.icon = icon
            }

        } catch {
            print("Error updating categories: \(error)")
        }
    }

//    private static func seedAccounts(
//        context: NSManagedObjectContext
//    ) {
//
//        let request = NSFetchRequest<Account>(
//            entityName: "Account"
//        )
//
//        let existingAccounts = (
//            try? context.fetch(request)
//        ) ?? []
//
//        guard existingAccounts.isEmpty else {
//            return
//        }
//
//        let accounts = [
//            ("Santander", "building.columns"),
//            ("Ahorros", "banknote"),
//            ("Wise", "creditcard")
//        ]
//
//        for (name, icon) in accounts {
//
//            let account = Account(context: context)
//
//            account.id = UUID()
//            account.name = name
//            account.icon = icon
//            account.balance = 0
//        }
//    }
}
