import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    private static let managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(
            forResource: "FinTrack",
            withExtension: "momd"
        ),
        let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Could not load FinTrack.momd")
        }

        return model
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(
            name: "FinTrack",
            managedObjectModel: Self.managedObjectModel
        )

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError(
                    "Unresolved Core Data error: \(error.localizedDescription)"
                )
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
        
    }
    
    
}
