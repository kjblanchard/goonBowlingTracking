//
//  GoonBowlingTrackerApp.swift
//  GoonBowlingTracker
//
//  Created by Kevin Blanchard on 5/28/23.
//

import SwiftUI

@main
struct GoonBowlingTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
