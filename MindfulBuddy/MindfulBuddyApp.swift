//
//  MindfulBuddyApp.swift
//  MindfulBuddy
//
//  Created by Anandha Ponnampalam on 28/03/2025.
//

import SwiftUI
import SwiftData

@main
struct MindfulBuddyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MeditationSession.self,
            UserPreferences.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            // Initialize default preferences if none exist
            let context = container.mainContext
            let fetchDescriptor = FetchDescriptor<UserPreferences>()
            if try context.fetch(fetchDescriptor).isEmpty {
                context.insert(UserPreferences())
            }
            return container
        } catch {
            let alert = UIAlertController(
                title: "Database Error",
                message: "Failed to initialize storage. Please reinstall the app.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            return WindowGroup {
                ContentView()
                    .modelContainer(sharedModelContainer)
                    .alert(isPresented: .constant(true)) {
                        Alert(
                            title: Text("Database Error"),
                            message: Text("Failed to initialize storage. Please reinstall the app."),
                            dismissButton: .default(Text("OK"))
                    }
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
