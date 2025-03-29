//
//  TimerView.swift
//  MindfulBuddy
//
//  Created by Anandha Ponnampalam on 28/03/2025.
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var timerDuration: TimeInterval = 300 // Default 5 minutes
    @State private var timeRemaining: TimeInterval = 300
    @State private var timerIsActive = false
    @State private var timer: Timer?
    @State private var showSessionSaved = false
    
    let durationOptions: [TimeInterval] = [60, 300, 600, 900, 1800] // 1, 5, 10, 15, 30 mins
    
    var body: some View {
        VStack(spacing: 30) {
            // Timer Display
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(.celadon)
                
                Circle()
                    .trim(from: 0, to: 1 - (timeRemaining / timerDuration))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(.celadon)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: timeRemaining)
                
                VStack {
                    Text(timeFormatted(timeRemaining))
                        .font(.system(size: 48, weight: .bold))
                        .monospacedDigit()
                    
                    if timerIsActive {
                        Text("Meditating...")
                            .font(.title3)
                            .foregroundColor(.celadon)
                    }
                }
            }
            .frame(width: 250, height: 250)
            .padding(.top, 40)
            
            // Duration Picker
            Picker("Duration", selection: $timerDuration) {
                ForEach(durationOptions, id: \.self) { duration in
                    Text("\(Int(duration / 60)) min")
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .disabled(timerIsActive)
            
            // Controls
            HStack(spacing: 30) {
                if timerIsActive {
                    Button(action: pauseTimer) {
                        Image(systemName: "pause.fill")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.celadon)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    Button(action: resetTimer) {
                        Image(systemName: "stop.fill")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                } else {
                    Button(action: startTimer) {
                        Image(systemName: "play.fill")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.celadon)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Meditation Timer")
        .onChange(of: timerDuration) { newDuration in
            if !timerIsActive {
                timeRemaining = newDuration
            }
        }
        .alert("Session Saved", isPresented: $showSessionSaved) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func timeFormatted(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        timerIsActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timerCompleted()
            }
        }
    }
    
    private func pauseTimer() {
        timerIsActive = false
        timer?.invalidate()
    }
    
    private func resetTimer() {
        timerIsActive = false
        timer?.invalidate()
        timeRemaining = timerDuration
    }
    
    private func timerCompleted() {
        timer?.invalidate()
        timerIsActive = false
        
        // Save the session
        let session = MeditationSession(
            startTime: Date(),
            duration: timerDuration,
            type: .timed
        )
        modelContext.insert(session)
        
        // Show confirmation
        showSessionSaved = true
        timeRemaining = timerDuration
    }
}

#Preview {
    TimerView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}
