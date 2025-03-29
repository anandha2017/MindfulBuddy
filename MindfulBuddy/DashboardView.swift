//
//  DashboardView.swift
//  MindfulBuddy
//
//  Created by Anandha Ponnampalam on 28/03/2025.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var sessions: [MeditationSession]
    @Environment(\.modelContext) private var modelContext
    
    private var totalSessions: Int {
        sessions.count
    }
    
    private var totalMinutes: Int {
        Int(sessions.reduce(0) { $0 + $1.duration }) / 60
    }
    
    private var streakCount: Int {
        // Simple streak calculation - will enhance later
        guard !sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        var streak = 1
        let sortedSessions = sessions.sorted { $0.startTime > $1.startTime }
        
        for i in 1..<sortedSessions.count {
            if calendar.isDate(sortedSessions[i-1].startTime, inSameDayAs: sortedSessions[i].startTime) {
                continue
            } else if calendar.isDate(sortedSessions[i-1].startTime, equalTo: calendar.date(byAdding: .day, value: -1, to: sortedSessions[i].startTime)!, toGranularity: .day) {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Overview
                    HStack(spacing: 15) {
                        StatCard(value: "\(totalSessions)", label: "Sessions", icon: "medal.fill")
                        StatCard(value: "\(totalMinutes)", label: "Minutes", icon: "clock.fill")
                        StatCard(value: "\(streakCount)", label: "Day Streak", icon: "flame.fill")
                    }
                    .padding(.horizontal)
                    
                    // Quick Start Button
                    NavigationLink(destination: TimerView()) {
                        Text("Start New Session")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.celadon)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .padding(.horizontal)
                    }
                    
                    // Recent Sessions
                    if !sessions.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recent Sessions")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(sessions.prefix(3)) { session in
                                SessionRow(session: session)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Mindful Buddy")
        }
    }
}

private struct SessionRow: View {
    let session: MeditationSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(session.startTime.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(Int(session.duration / 60)) min \(session.type.rawValue.capitalized) session")
                    .font(.headline)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}
