import XCTest
@testable import MindfulBuddy

final class StatsCalculationTests: XCTestCase {
    var testSessions: [MeditationSession] = []
    let calendar = Calendar.current
    
    // MARK: - DashboardView Stats Tests
    
    func testTotalSessions() {
        // Empty case
        XCTAssertEqual(DashboardView.calculateTotalSessions([]), 0)
        
        // Single session
        testSessions = [createTestSession()]
        XCTAssertEqual(DashboardView.calculateTotalSessions(testSessions), 1)
        
        // Multiple sessions
        testSessions.append(contentsOf: [
            createTestSession(duration: 600), // 10 min
            createTestSession(duration: 1800) // 30 min
        ])
        XCTAssertEqual(DashboardView.calculateTotalSessions(testSessions), 3)
    }
    
    func testTotalMinutes() {
        // Empty case
        XCTAssertEqual(DashboardView.calculateTotalMinutes([]), 0)
        
        // Exact minutes
        testSessions = [createTestSession(duration: 300)] // 5 min
        XCTAssertEqual(DashboardView.calculateTotalMinutes(testSessions), 5)
        
        // Partial minutes (should floor)
        testSessions.append(createTestSession(duration: 359)) // 5.98 min → 5
        XCTAssertEqual(DashboardView.calculateTotalMinutes(testSessions), 10)
        
        // Edge case: 0 duration
        testSessions.append(createTestSession(duration: 0))
        XCTAssertEqual(DashboardView.calculateTotalMinutes(testSessions), 10)
    }
    
    func testStreakCount() {
        // Empty case
        XCTAssertEqual(DashboardView.calculateStreakCount([]), 0)
        
        // Single session
        testSessions = [createTestSession()]
        XCTAssertEqual(DashboardView.calculateStreakCount(testSessions), 1)
        
        // Consecutive days
        let today = Date()
        testSessions = [
            createTestSession(startTime: today),
            createTestSession(startTime: calendar.date(byAdding: .day, value: -1, to: today)!),
            createTestSession(startTime: calendar.date(byAdding: .day, value: -2, to: today)!)
        ]
        XCTAssertEqual(DashboardView.calculateStreakCount(testSessions), 3)
        
        // Broken streak
        testSessions.append(
            createTestSession(startTime: calendar.date(byAdding: .day, value: -4, to: today)!)
        )
        XCTAssertEqual(DashboardView.calculateStreakCount(testSessions), 3)
        
        // Multiple sessions same day
        testSessions.append(
            createTestSession(startTime: calendar.date(byAdding: .hour, value: -2, to: today)!)
        )
        XCTAssertEqual(DashboardView.calculateStreakCount(testSessions), 3)
        
        // Edge case: crossing year boundary
        let dec31 = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31))!
        let jan1 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        testSessions = [
            createTestSession(startTime: jan1),
            createTestSession(startTime: dec31)
        ]
        XCTAssertEqual(DashboardView.calculateStreakCount(testSessions), 2)
    }
    
    // MARK: - Helper Methods
    
    private func createTestSession(
        startTime: Date = Date(),
        duration: TimeInterval = 300, // 5 min
        type: SessionType = .timed,
        notes: String? = nil
    ) -> MeditationSession {
        return MeditationSession(
            startTime: startTime,
            duration: duration,
            type: type,
            notes: notes
        )
    }
    // MARK: - ProgressView Stats Tests
    
    func testFilteredSessions() {
        let today = Date()
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: today)!
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today)!
        
        testSessions = [
            createTestSession(startTime: today),
            createTestSession(startTime: oneWeekAgo),
            createTestSession(startTime: oneMonthAgo),
            createTestSession(startTime: oneYearAgo)
        ]
        
        // Week filter
        var filtered = ProgressView.filterSessions(testSessions, timeFrame: .week)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.startTime, today)
        
        // Month filter
        filtered = ProgressView.filterSessions(testSessions, timeFrame: .month)
        XCTAssertEqual(filtered.count, 2)
        
        // Year filter
        filtered = ProgressView.filterSessions(testSessions, timeFrame: .year)
        XCTAssertEqual(filtered.count, 3)
        
        // All time filter
        filtered = ProgressView.filterSessions(testSessions, timeFrame: .all)
        XCTAssertEqual(filtered.count, 4)
    }
    
    func testFilteredTotalMinutes() {
        testSessions = [
            createTestSession(duration: 300), // 5 min
            createTestSession(duration: 600), // 10 min
            createTestSession(duration: 1800) // 30 min
        ]
        
        let total = ProgressView.calculateTotalMinutes(testSessions)
        XCTAssertEqual(total, 45) // 5 + 10 + 30
    }
    
    func testAverageMinutes() {
        // Empty case
        XCTAssertEqual(ProgressView.calculateAverageMinutes([]), 0)
        
        // Single session
        testSessions = [createTestSession(duration: 300)] // 5 min
        XCTAssertEqual(ProgressView.calculateAverageMinutes(testSessions), 5)
        
        // Multiple sessions
        testSessions.append(contentsOf: [
            createTestSession(duration: 600), // 10 min
            createTestSession(duration: 900) // 15 min
        ])
        XCTAssertEqual(ProgressView.calculateAverageMinutes(testSessions), 10) // (5+10+15)/3
    }
}

// MARK: - Testable Extensions

extension ProgressView {
    static func filterSessions(_ sessions: [MeditationSession], timeFrame: TimeFrame) -> [MeditationSession] {
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
    
    static func calculateTotalMinutes(_ sessions: [MeditationSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        return Int(sessions.reduce(0) { $0 + $1.duration }) / 60
    }
    
    static func calculateAverageMinutes(_ sessions: [MeditationSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        return Int(sessions.reduce(0) { $0 + $1.duration }) / 60 / sessions.count
    }
}

extension DashboardView {
    // Extract calculations for testability
    static func calculateTotalSessions(_ sessions: [MeditationSession]) -> Int {
        return sessions.count
    }
    
    static func calculateTotalMinutes(_ sessions: [MeditationSession]) -> Int {
        return Int(sessions.reduce(0) { $0 + $1.duration }) / 60
    }
    
    static func calculateStreakCount(_ sessions: [MeditationSession]) -> Int {
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
}
