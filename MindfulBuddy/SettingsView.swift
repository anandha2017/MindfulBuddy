//
//  SettingsView.swift
//  MindfulBuddy
//
//  Created by Anandha Ponnampalam on 28/03/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showReminderTimePicker = false
    @State private var showResetConfirmation = false
    
    private var userPreferences: UserPreferences {
        preferences.first ?? UserPreferences()
    }
    
    var body: some View {
        Form {
            // Appearance Section
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: Binding(
                    get: { userPreferences.darkModeEnabled },
                    set: { newValue in
                        userPreferences.darkModeEnabled = newValue
                        try? modelContext.save()
                    }
                ))
                .tint(.celadon)
            }
            
            // Session Preferences
            Section(header: Text("Session Preferences")) {
                Stepper(value: Binding(
                    get: { Int(userPreferences.preferredDuration / 60) },
                    set: { newValue in
                        userPreferences.preferredDuration = TimeInterval(newValue * 60)
                        try? modelContext.save()
                    }
                ), in: 1...60, step: 1) {
                    Text("Default Duration: \(Int(userPreferences.preferredDuration / 60)) min")
                }
            }
            
            // App Section
            Section {
                Button(action: { showResetConfirmation = true }) {
                    Text("Reset All Data")
                        .foregroundColor(.red)
                }
                .alert("Reset All Data?", isPresented: $showResetConfirmation) {
                    Button("Reset", role: .destructive) {
                        resetAllData()
                    }
                    Button("Cancel", role: .cancel) {}
                }
                
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            if preferences.isEmpty {
                modelContext.insert(UserPreferences())
            }
        }
    }
    
    private func resetAllData() {
        do {
            try modelContext.delete(model: MeditationSession.self)
            try modelContext.save()
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
}
