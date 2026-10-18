import SwiftUI
import CoreData

@main
struct FinTrackApp: App {

    let persistenceController = PersistenceController.shared
    
    init() {
        AppSeeder.seed(
            context: persistenceController.container.viewContext
        )
    }

    var body: some Scene {

        WindowGroup {

            ContentView()
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
        }
    }
}
