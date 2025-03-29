//
//  MeditationSession.swift
//  MindfulBuddy
//
//  Created by Anandha Ponnampalam on 28/03/2025.
//

import Foundation
import SwiftData

enum SessionType: String, Codable {
    case timed
    case guided
}

@Model
final class MeditationSession {
    var startTime: Date
    var duration: TimeInterval
    var type: SessionType
    var notes: String?
    
    init(startTime: Date, duration: TimeInterval, type: SessionType, notes: String? = nil) {
        self.startTime = startTime
        self.duration = duration
        self.type = type
        self.notes = notes
    }
}

@Model
final class UserPreferences {
    var preferredDuration: TimeInterval
    var darkModeEnabled: Bool
    
    init(preferredDuration: TimeInterval = 300, // 5 minutes
         darkModeEnabled: Bool = false) {
        self.preferredDuration = preferredDuration
        self.darkModeEnabled = darkModeEnabled
    }
}
