//
//  JournalFeatureView.swift
//  Offleaf
//
//  Created by Assistant on 10/16/25.
//

import SwiftUI
import UIKit

// Journal Entry Model
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let content: String
    let mood: String?
    let trigger: String?
    
    init(date: Date, content: String, mood: String? = nil, trigger: String? = nil) {
        self.id = UUID()
        self.date = date
        self.content = content
        self.mood = mood
        self.trigger = trigger
    }
}

// Journal Storage Manager
class JournalManager: ObservableObject {
    @Published var entries: [JournalEntry] = []
    
    private let saveKey = "JournalEntries"
    
    init() {
        loadEntries()
    }
    
    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                let decoded = try JSONDecoder().decode([JournalEntry].self, from: data)
                entries = decoded
            } catch {
                print("[Journal] ERROR: Failed to decode entries: \(error)")
                
                // Try to recover from backup
                if let backupData = UserDefaults.standard.data(forKey: "\(saveKey)_backup") {
                    do {
                        let backupEntries = try JSONDecoder().decode([JournalEntry].self, from: backupData)
                        entries = backupEntries
                        save() // Re-save to main key
                        print("[Journal] Recovered \(entries.count) entries from backup")
                    } catch {
                        print("[Journal] ERROR: Backup also corrupted: \(error)")
                        // Save corrupted data for debugging
                        UserDefaults.standard.set(data, forKey: "\(saveKey)_corrupted")
                        entries = []
                    }
                } else {
                    entries = []
                }
            }
        }
    }
    
    func saveEntry(_ entry: JournalEntry) {
        entries.insert(entry, at: 0) // Most recent first
        save()
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
    
    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let encoded = try encoder.encode(entries)
            
            // Create backup before overwriting (keep last 2 versions)
            if let existingData = UserDefaults.standard.data(forKey: saveKey) {
                UserDefaults.standard.set(existingData, forKey: "\(saveKey)_backup")
            }
            
            // Save new data
            UserDefaults.standard.set(encoded, forKey: saveKey)
            
            // Verify save succeeded
            if UserDefaults.standard.data(forKey: saveKey) != encoded {
                print("[Journal] WARNING: Save verification failed")
            }
        } catch {
            print("[Journal] CRITICAL: Failed to encode \(entries.count) entries: \(error)")
            // Don't overwrite existing data if encoding fails
        }
    }
}

struct JournalFeatureView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var journalManager = JournalManager()
    @State private var showingNewEntry = false
    @State private var searchText = ""
    @State private var animateGradient = false
    @State private var showContent = false
    @State private var floatingAnimation = false
    
    var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return journalManager.entries
        } else {
            return journalManager.entries.filter { 
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Vibrant background orbs
            JournalBackgroundView(animating: $floatingAnimation)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced Header with glass morphism
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 24, weight: .medium))
                            Text("Back")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: { showingNewEntry = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                            Text("Entry")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.7, blue: 0.4),
                                    Color(red: 0.25, green: 0.6, blue: 0.35)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 8, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Enhanced search bar with glass morphism
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    TextField("", text: $searchText, prompt: Text("Search entries...").foregroundColor(.white.opacity(0.3)))
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .autocapitalization(.none)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .scaleEffect(showContent ? 1 : 0.9)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: showContent)
                
                if journalManager.entries.isEmpty {
                    // Enhanced empty state
                    VStack(spacing: 32) {
                        Spacer()
                        
                        // Animated journal icon with glow
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 0.6, green: 0.8, blue: 1).opacity(0.3),
                                            Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.1),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 200, height: 200)
                                .blur(radius: 20)
                                .scaleEffect(floatingAnimation ? 1.2 : 0.8)
                                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: floatingAnimation)
                            
                            Image(systemName: "pencil.and.scribble")
                                .font(.system(size: 56, weight: .medium))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(floatingAnimation ? 5 : -5))
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floatingAnimation)
                        }
                        
                        VStack(spacing: 16) {
                            Text("Your Journey Awaits")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Capture your thoughts, track your progress,\nand celebrate your strength")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        
                        Button(action: { showingNewEntry = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Write First Entry")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.3, green: 0.7, blue: 0.4),
                                        Color(red: 0.25, green: 0.6, blue: 0.35)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.4), radius: 12, y: 4)
                        }
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showContent)
                        
                        Spacer()
                    }
                } else {
                    // Journal entries list with animations
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                                EnhancedJournalCard(
                                    entry: entry,
                                    index: index,
                                    showContent: showContent
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        journalManager.deleteEntry(entry)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateGradient = true
                showContent = true
                floatingAnimation = true
            }
        }
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView { entry in
                journalManager.saveEntry(entry)
            }
        }
    }
}

// Enhanced journal card with glass morphism
struct EnhancedJournalCard: View {
    let entry: JournalEntry
    let index: Int
    let showContent: Bool
    let onDelete: () -> Void
    @State private var showingDetail = false
    @State private var isPressed = false
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: entry.date)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        Button(action: { 
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showingDetail.toggle()
            }
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with date and mood
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(formattedDate)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.4))
                            Text(formattedTime)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    Spacer()
                    
                    if let mood = entry.mood {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.1),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            
                            Text(mood)
                                .font(.system(size: 26))
                        }
                    }
                }
                
                // Content preview/full
                Text(entry.content)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(showingDetail ? nil : 3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .animation(.easeInOut(duration: 0.2), value: showingDetail)
                
                if showingDetail {
                    VStack(alignment: .leading, spacing: 12) {
                        if let trigger = entry.trigger, !trigger.isEmpty {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "bolt.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 1, green: 0.7, blue: 0.3))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Trigger")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text(trigger)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.top, 8)
                        }
                        
                        HStack {
                            Button(action: onDelete) {
                                HStack(spacing: 6) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14))
                                    Text("Delete Entry")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(red: 1, green: 0.4, blue: 0.4).opacity(0.15))
                                )
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
                
                // Expand/collapse indicator
                HStack {
                    Spacer()
                    Image(systemName: showingDetail ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial.opacity(0.15))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1) {} onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
        .scaleEffect(showContent ? 1 : 0.8)
        .opacity(showContent ? 1 : 0)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.7)
            .delay(Double(index) * 0.05 + 0.2),
            value: showContent
        )
    }
}

// Journal background with animated orbs
struct JournalBackgroundView: View {
    @Binding var animating: Bool
    
    var body: some View {
        ZStack {
            // Primary blue orb for creativity
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.4, green: 0.6, blue: 1).opacity(0.3),
                            Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.2),
                            Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 30)
                .position(x: UIScreen.main.bounds.width - 100, y: 250)
                .rotationEffect(.degrees(animating ? 360 : 0))
                .animation(.linear(duration: 80).repeatForever(autoreverses: false), value: animating)
            
            // Secondary purple orb for reflection
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.25),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .frame(width: 250, height: 250)
                .blur(radius: 25)
                .position(x: 80, y: UIScreen.main.bounds.height - 150)
                .scaleEffect(animating ? 1.3 : 0.7)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animating)
            
            // Small accent orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 150, height: 150)
                .blur(radius: 20)
                .position(x: UIScreen.main.bounds.width / 2, y: 100)
                .scaleEffect(animating ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animating)
        }
    }
}

struct NewJournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (JournalEntry) -> Void
    
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
                    
                    Button(action: {
                        let entry = JournalEntry(
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
                    VStack(spacing: 32) {
                        // Title section
                        VStack(spacing: 12) {
                            Image(systemName: "pencil.and.scribble")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(Color(red: 0.6, green: 0.8, blue: 1))
                                .scaleEffect(animateGradient ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateGradient)
                            
                            Text("Capture This Moment")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Your thoughts matter")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 28) {
                            // Mood selector with enhanced design
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "face.smiling")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("How are you feeling?")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
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
                            }
                            
                            // Trigger field with enhanced design
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "bolt.circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("What triggered this? (optional)")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                TextField("", text: $trigger, prompt: Text("Stress, boredom, social situation...").foregroundColor(.white.opacity(0.3)))
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
                            
                            // Main content with enhanced design
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "text.alignleft")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Write your thoughts")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                ZStack(alignment: .topLeading) {
                                    if content.isEmpty {
                                        Text("What's on your mind? How was your day? What are you grateful for?")
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
                        }
                        .padding(.horizontal, 24)
                        
                        // Encouragement footer
                        HStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.7))
                            Text("Every entry is a step towards healing")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            // Don't auto-focus - let user tap to start typing
            withAnimation(.easeInOut(duration: 1)) {
                animateGradient = true
            }
        }
    }
}

struct JournalFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        JournalFeatureView()
    }
}
