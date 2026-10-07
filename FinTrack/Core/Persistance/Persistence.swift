import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {

        container = NSPersistentContainer(
            name: "FinTrack"
        )

        if inMemory {
            container.persistentStoreDescriptions.first?
                .url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in

            if let error = error {

                fatalError(
                    "Unresolved Core Data error: \(error)"
                )
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
    }
}
