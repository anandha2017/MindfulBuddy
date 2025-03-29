    //
//  ProgressView.swift
//  MindfulBuddy
//
//  Created by Anandha Ponnampalam on 28/03/2025.
//

import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {
    @Query private var sessions: [MeditationSession]
    @State private var timeFrame: TimeFrame = .week
    private let calendar = Calendar.current
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"
    }
    
    private var filteredSessions: [MeditationSession] {
        let calendar = Calendar.current
        let now = Date()
        
        return sessions.filter { session in
            switch timeFrame {
            case .week:
                return calendar.isDate(session.startTime, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(session.startTime, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(session.startTime, equalTo: now, toGranularity: .year)
            case .all:
                return true
            }
        }
    }
    
    private var totalMinutes: Int {
        Int(filteredSessions.reduce(0) { $0 + $1.duration }) / 60
    }
    
    private var averageMinutes: Int {
        guard !filteredSessions.isEmpty else { return 0 }
        return totalMinutes / filteredSessions.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Time Frame Picker
                Picker("Time Frame", selection: $timeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { frame in
                        Text(frame.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Stats Summary
                HStack(spacing: 15) {
                    StatCard(value: "\(filteredSessions.count)", label: "Sessions", icon: "medal.fill")
                    StatCard(value: "\(totalMinutes)", label: "Minutes", icon: "clock.fill")
                    StatCard(value: "\(averageMinutes)", label: "Avg/Min", icon: "chart.bar.fill")
                }
                .padding(.horizontal)
                
                // Duration Chart
                VStack(alignment: .leading) {
                    Text("Session Duration")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart {
                        ForEach(filteredSessions) { session in
                            BarMark(
                                x: .value("Date", session.startTime, unit: .day),
                                y: .value("Minutes", session.duration / 60)
                            )
                            .foregroundStyle(Color.celadon.gradient)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.day())
                        }
                    }
                    .frame(height: 200)
                    .padding()
                }
                
                // Frequency Chart
                VStack(alignment: .leading) {
                    Text("Daily Frequency")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart {
                        ForEach(filteredSessions) { session in
                            BarMark(
                                x: .value("Day", session.startTime, unit: .weekday),
                                y: .value("Count", 1)
                            )
                            .foregroundStyle(Color.deepTeal.gradient)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine()
                            if let date = value.as(Date.self) {
                                AxisValueLabel(
                                self.calendar.component(.weekday, from: date) == 1 ? "Sun" :
                                self.calendar.component(.weekday, from: date) == 2 ? "Mon" :
                                self.calendar.component(.weekday, from: date) == 3 ? "Tue" :
                                self.calendar.component(.weekday, from: date) == 4 ? "Wed" :
                                self.calendar.component(.weekday, from: date) == 5 ? "Thu" :
                                self.calendar.component(.weekday, from: date) == 6 ? "Fri" : "Sat"
                                )
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Your Progress")
    }
}

#Preview {
    ProgressView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}
