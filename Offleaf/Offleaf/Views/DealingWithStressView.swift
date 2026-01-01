//
//  DealingWithStressView.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI

struct DealingWithStressView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingTriggerExercise = false
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer().frame(width: 16)
                    
                    LeafLogoView(size: 56)
                    
                    Text("Learn")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title
                        Text("Dealing with Stress?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                        
                        // What are triggers section
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("What are triggers?")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Triggers are people, places, things, or emotions that make you want to drink or use. Recognizing them is the first step to managing them.")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white.opacity(0.8))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                            )
                            
                            // Common triggers section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Common triggers include:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    TriggerItem(text: "Social situations")
                                    TriggerItem(text: "Stress or anxiety")
                                    TriggerItem(text: "Certain locations")
                                    TriggerItem(text: "Specific times of day")
                                    TriggerItem(text: "Emotions like boredom or loneliness")
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                            )
                            
                            // Experts suggest section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Experts suggest:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Write down three situations that trigger you. Next to each, write one healthy action you can take instead.")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white.opacity(0.8))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Try this button
                        Button(action: {
                            showingTriggerExercise = true
                        }) {
                            Text("Try this")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .cornerRadius(28)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        
                        Spacer(minLength: 80)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingTriggerExercise) {
            TriggerExerciseView()
        }
    }
}

struct TriggerItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("•")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
            
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

struct TriggerExerciseView: View {
    @Environment(\.dismiss) var dismiss
    @State private var triggers: [TriggerPlan] = [
        TriggerPlan(),
        TriggerPlan(),
        TriggerPlan()
    ]
    @State private var savedTriggers: [[String: String]] = []
    @State private var hasCompleted = false
    @State private var showingSuccess = false
    @FocusState private var focusedField: Int?
    
    struct TriggerPlan: Identifiable {
        let id = UUID()
        var trigger: String = ""
        var healthyAction: String = ""
    }
    
    var isValid: Bool {
        triggers.allSatisfy { !$0.trigger.isEmpty && !$0.healthyAction.isEmpty }
    }
    
    @ViewBuilder
    var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text("Trigger Exercise")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button("Save") {
                saveTriggers()
            }
            .foregroundColor(isValid ? Color(red: 0.3, green: 0.7, blue: 0.4) : .white.opacity(0.3))
            .disabled(!isValid)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    var instructionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
                
                Text("Identify Your Triggers")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Write down three situations that trigger you to use cannabis. Then, plan a healthy alternative for each one.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    @ViewBuilder
    func triggerBadge(for index: Int) -> some View {
        HStack {
            Text("Trigger #\(index + 1)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.2))
                )
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func triggerTextField(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What triggers you?")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            TextField("e.g., After work stress, social events...", text: $triggers[index].trigger)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .tint(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == index * 2 ? 
                                       Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.5) :
                                       Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .focused($focusedField, equals: index * 2)
        }
    }
    
    @ViewBuilder
    func actionTextField(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Healthy alternative")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            TextField("e.g., Go for a walk, call a friend...", text: $triggers[index].healthyAction)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .tint(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == index * 2 + 1 ? 
                                       Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.5) :
                                       Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .focused($focusedField, equals: index * 2 + 1)
        }
    }
    
    @ViewBuilder
    func triggerInputView(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            triggerBadge(for: index)
            triggerTextField(for: index)
            actionTextField(for: index)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    var examplesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
                
                Text("Examples")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ExampleRow(trigger: "Feeling lonely at night", action: "Call a supportive friend or family member")
                ExampleRow(trigger: "Seeing others smoke", action: "Remove myself from the situation")
                ExampleRow(trigger: "Feeling anxious", action: "Practice deep breathing exercises")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.1))
        )
    }
    
    @ViewBuilder
    var savedTriggersView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                
                Text("Your Previous Triggers")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            if savedTriggers.isEmpty {
                Text("No triggers saved yet. Complete the exercise above to save your first trigger plan.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .italic()
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(savedTriggers.prefix(3), id: \.self) { triggerData in
                        if let trigger = triggerData["trigger"], let action = triggerData["action"] {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(trigger)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        Text("→ \(action)")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        instructionsView
                        
                        ForEach(triggers.indices, id: \.self) { index in
                            triggerInputView(for: index)
                        }
                        
                        examplesView
                        
                        savedTriggersView
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .overlay(
            Group {
                if showingSuccess {
                    SuccessOverlay()
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                }
            }
        )
        .onAppear {
            loadSavedTriggers()
        }
    }
    
    func loadSavedTriggers() {
        // Load from secure storage first
        if let data = SecureHealthDataStore.shared.loadSecureData([[String: String]].self, for: "userTriggerPlans") {
            savedTriggers = data
        } else if let data = UserDefaults.standard.array(forKey: "userTriggerPlans") as? [[String: String]] {
            // Migrate from UserDefaults if exists
            savedTriggers = data
            _ = SecureHealthDataStore.shared.saveSecureData(data, for: "userTriggerPlans")
            UserDefaults.standard.removeObject(forKey: "userTriggerPlans")
        }
    }
    
    func saveTriggers() {
        // Save to secure storage for sensitive health data
        let triggerData = triggers.map { ["trigger": $0.trigger, "action": $0.healthyAction] }
        _ = SecureHealthDataStore.shared.saveSecureData(triggerData, for: "userTriggerPlans")
        
        // Update local state
        savedTriggers = triggerData
        
        // Show success animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingSuccess = true
        }
        
        // Dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dismiss()
        }
    }
}

struct ExampleRow: View {
    let trigger: String
    let action: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trigger)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("→ \(action)")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

struct SuccessOverlay: View {
    @State private var scale = 0.5
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.3, green: 0.7, blue: 0.4))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                
                VStack(spacing: 8) {
                    Text("Great Work!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your trigger plan has been saved")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

struct DealingWithStressView_Previews: PreviewProvider {
    static var previews: some View {
        DealingWithStressView()
    }
}