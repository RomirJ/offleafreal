//
//  RelapsedView.swift
//  Offleaf
//
//  Created by Assistant on 10/16/25.
//

import SwiftUI

// Local structure for relapse journaling
struct RelapseJournalEntry: Codable {
    let id: UUID
    let date: Date
    let content: String
    let mood: String?
    let trigger: String?
    
    init(id: UUID = UUID(), date: Date, content: String, mood: String? = nil, trigger: String? = nil) {
        self.id = id
        self.date = date
        self.content = content
        self.mood = mood
        self.trigger = trigger
    }
}

struct RelapsedView: View {
    @StateObject private var streakManager = StreakManager.shared
    @Environment(\.dismiss) var dismiss
    @AppStorage("quitDate") private var quitDateString = ""
    @AppStorage("checkInDates") private var checkInDatesString = ""
    @AppStorage("lastCheckInDate") private var lastCheckInDateString = ""
    @State private var showingJournal = false
    @State private var shouldResetAndDismiss = false
    var dismissAll: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Warm gradient for compassion
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.05),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header - moved up with reduced top padding
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                            Text("Back")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Relapsed")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 1, green: 0.6, blue: 0.4))
                    
                    Spacer()
                    
                    // Balance spacing
                    Color.clear
                        .frame(width: 60, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)  // Reduced from 60 to move buttons up
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        // Compassionate message
                        VStack(spacing: 32) {
                            Text("Don't worry\nabout it")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Slip-ups happen and can make you feel bad, but it's crucial not to be too hard on yourself. You're getting closer to freedom.")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 24)
                        }
                        .padding(.top, 40)
                        
                        // Journal feelings button
                        Button(action: {
                            showingJournal = true
                        }) {
                            HStack {
                                Image(systemName: "pencil.line")
                                    .font(.system(size: 20, weight: .medium))
                                Text("Journal Feelings")
                                    .font(.system(size: 18, weight: .semibold))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .frame(height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 0.08, green: 0.08, blue: 0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Motivational quote
                        VStack(spacing: 40) {
                            Text("Choosing to quit\ncannabis is a step\ntowards\nbecoming your\nbest self.")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                            
                            // Success tips
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Tips for success:")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    TipRow(text: "Remove all cannabis from your home")
                                    TipRow(text: "Delete dealer contacts")
                                    TipRow(text: "Avoid triggering situations")
                                    TipRow(text: "Stay busy with healthy activities")
                                    TipRow(text: "Reach out for support when needed")
                                }
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Reset counter button
                        Button(action: {
                            resetCounter()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Reset Counter")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.9, green: 0.5, blue: 0.3),
                                        Color(red: 0.8, green: 0.4, blue: 0.2)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(30)
                            .shadow(color: Color(red: 0.9, green: 0.5, blue: 0.3).opacity(0.3), radius: 10, y: 4)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingJournal) {
            RelapseJournalEntryView { entry in
                // Save journal entry directly to UserDefaults
                saveJournalEntry(entry)
            }
        }
    }
    
    func saveJournalEntry(_ entry: RelapseJournalEntry) {
        // Load existing entries
        var entries: [RelapseJournalEntry] = []
        if let data = UserDefaults.standard.data(forKey: "relapseJournalEntries") {
            if let decoded = try? JSONDecoder().decode([RelapseJournalEntry].self, from: data) {
                entries = decoded
            }
        }
        
        // Add new entry
        entries.append(entry)
        
        // Keep only last 100 entries to prevent unbounded growth
        if entries.count > 100 {
            entries = Array(entries.suffix(100))
        }
        
        // Save back to UserDefaults
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "relapseJournalEntries")
        }
    }
    
    func resetCounter() {
        // Reset the quit date to now
        let formatter = ISO8601DateFormatter()
        quitDateString = formatter.string(from: Date())
        streakManager.resetStreak()
        checkInDatesString = ""
        lastCheckInDateString = ""
        DailyCheckInStore.clear()
        
        // Set flag for animation on home screen
        UserDefaults.standard.set(true, forKey: "justResetCounter")
        
        Task {
            await NotificationManager.shared.resetProgressNotifications()
        }

        // Post notification to trigger animation
        NotificationCenter.default.post(name: Notification.Name("CounterReset"), object: nil)
        
        // Dismiss all modals to go back to home
        if let dismissAll = dismissAll {
            dismissAll()
        } else {
            dismiss()
        }
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("•")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// Custom journal entry view specifically for relapse journaling
struct RelapseJournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (RelapseJournalEntry) -> Void
    
    @State private var content = ""
    @State private var selectedMood = ""
    @State private var trigger = ""
    @FocusState private var isFocused: Bool
    @State private var animateGradient = false
    
    let moods = ["😔", "😐", "😊", "😤", "😰", "💪"]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.12, blue: 0.2).opacity(0.5),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced Header
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    Text("Journal")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        let entry = RelapseJournalEntry(
                            date: Date(),
                            content: content,
                            mood: selectedMood.isEmpty ? nil : selectedMood,
                            trigger: trigger.isEmpty ? nil : trigger
                        )
                        onSave(entry)
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(content.isEmpty ? .white.opacity(0.3) : .white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: content.isEmpty ? [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.08)
                                    ] : [
                                        Color(red: 0.3, green: 0.7, blue: 0.4),
                                        Color(red: 0.25, green: 0.6, blue: 0.35)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(
                                color: content.isEmpty ? .clear : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3),
                                radius: 8,
                                y: 2
                            )
                    }
                    .disabled(content.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Pre-filled prompt for relapse journaling
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Reflect on Your Experience")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("How are you feeling? What triggered the relapse? What will you do differently next time?")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.3))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 12)
                                }
                                
                                TextEditor(text: $content)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .focused($isFocused)
                            }
                            .frame(minHeight: 250)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                isFocused ?
                                                Color(red: 0.4, green: 0.6, blue: 1).opacity(0.5) :
                                                Color.white.opacity(0.1),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Mood selector
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("How are you feeling now?")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.horizontal, 24)
                            
                            HStack(spacing: 12) {
                                ForEach(moods, id: \.self) { mood in
                                    Button(action: { 
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedMood = mood
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    selectedMood == mood ?
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 0.4, green: 0.6, blue: 1).opacity(0.3),
                                                            Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.2)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ) :
                                                    LinearGradient(
                                                        colors: [
                                                            Color.white.opacity(0.08),
                                                            Color.white.opacity(0.05)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 52, height: 52)
                                                .overlay(
                                                    Circle()
                                                        .stroke(
                                                            selectedMood == mood ?
                                                            Color(red: 0.4, green: 0.6, blue: 1).opacity(0.5) :
                                                            Color.white.opacity(0.1),
                                                            lineWidth: 1
                                                        )
                                                )
                                            
                                            Text(mood)
                                                .font(.system(size: 28))
                                        }
                                        .scaleEffect(selectedMood == mood ? 1.1 : 1.0)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Trigger field
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "bolt.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("What triggered this?")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            TextField("", text: $trigger, prompt: Text("Stress, social situation, boredom...").foregroundColor(.white.opacity(0.3)))
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }
                        .padding(.horizontal, 24)
                        
                        // Encouragement footer
                        HStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.7))
                            Text("Every setback is a setup for a comeback")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            // Auto-focus on the text field
            isFocused = true
            withAnimation(.easeInOut(duration: 1)) {
                animateGradient = true
            }
        }
    }
}

struct RelapsedView_Previews: PreviewProvider {
    static var previews: some View {
        RelapsedView()
    }
}
