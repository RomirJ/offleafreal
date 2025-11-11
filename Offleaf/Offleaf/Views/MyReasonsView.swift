//
//  MyReasonsView.swift
//  Offleaf
//

import SwiftUI

struct MyReasonsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var reasons: [String] = []
    @State private var newReason = ""
    @State private var showingAddReason = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("My Reasons")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingAddReason = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 10)
                
                if reasons.isEmpty && !showingAddReason {
                    // Empty state
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.5))
                        
                        Text("No reasons added yet")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Add your personal reasons for quitting.\nThey'll help you stay motivated.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                        
                        Button(action: { showingAddReason = true }) {
                            Text("Add Your First Reason")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Add new reason field
                            if showingAddReason {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Add a new reason")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    HStack {
                                        TextField("e.g., To be healthier for my family", text: $newReason)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .tint(.white)
                                            .focused($isInputFocused)
                                            .onSubmit {
                                                addReason()
                                            }
                                        
                                        Button(action: addReason) {
                                            Text("Add")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(newReason.isEmpty ? .white.opacity(0.3) : Color(red: 0.3, green: 0.7, blue: 0.4))
                                        }
                                        .disabled(newReason.isEmpty)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.5), lineWidth: 1)
                                            )
                                    )
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .onAppear {
                                    isInputFocused = true
                                }
                            }
                            
                            // Existing reasons
                            ForEach(Array(reasons.enumerated()), id: \.offset) { index, reason in
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        
                                        Text("\(index + 1)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                                    }
                                    
                                    Text(reason)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Button(action: { removeReason(at: index) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.05))
                                )
                                .padding(.horizontal, 20)
                            }
                            
                            // Inspirational message
                            if !reasons.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
                                    
                                    Text("Remember these reasons when times get tough")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 20)
                                .padding(.horizontal, 40)
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.top, showingAddReason ? 0 : 20)
                    }
                }
            }
        }
        .onAppear {
            loadReasons()
        }
    }
    
    private func loadReasons() {
        if let savedReasons = UserDefaults.standard.array(forKey: "userQuitReasons") as? [String] {
            reasons = savedReasons
        }
    }
    
    private func addReason() {
        guard !newReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        reasons.append(newReason)
        UserDefaults.standard.set(reasons, forKey: "userQuitReasons")
        
        newReason = ""
        showingAddReason = false
        isInputFocused = false
    }
    
    private func removeReason(at index: Int) {
        reasons.remove(at: index)
        UserDefaults.standard.set(reasons, forKey: "userQuitReasons")
    }
}

struct MyReasonsView_Previews: PreviewProvider {
    static var previews: some View {
        MyReasonsView()
    }
}