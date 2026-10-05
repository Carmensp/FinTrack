//
//  FinTrackApp.swift
//  FinTrack
//
//  Created by Carmen on 05/10/2026.
//

import SwiftUI
import CoreData

@main
struct FinTrackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
