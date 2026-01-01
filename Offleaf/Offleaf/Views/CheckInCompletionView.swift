//
//  CheckInCompletionView.swift
//  Offleaf
//
//  Created by Assistant on 10/15/25.
//

import SwiftUI
import UIKit

struct CheckInCompletionView: View {
    @StateObject private var streakManager = StreakManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showConfetti = false
    @AppStorage("userName") private var userName = ""
    @State private var isEditingName = false
    @State private var draftName = ""
    var onDismiss: (() -> Void)? = nil

    private var displayName: String {
        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "@name" : trimmed
    }

    private var streakMessage: String {
        switch streakManager.currentStreak {
        case ..<1:
            return "You've completed your first check-in!"
        case 1:
            return "You've checked in today. Keep it going!"
        default:
            return "You've checked in for \(streakManager.currentStreak) days straight"
        }
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // X button
                HStack {
                    Spacer()
                    
                    Button(action: { 
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                            dismiss()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer()
                
                VStack(spacing: 32) {
                    // Party emoji with animation
                    Text("🎉")
                        .font(.system(size: 80))
                        .scaleEffect(showConfetti ? 1.2 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatCount(1, autoreverses: true), value: showConfetti)
                    
                    VStack(spacing: 12) {
                        Button {
                            draftName = userName
                            isEditingName = true
                        } label: {
                            Text("Nice work, \(displayName)!")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .underline(displayName == "@name", color: .white.opacity(0.6))
                        }
                        .buttonStyle(.plain)

                        Text(streakMessage)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Continue button
                Button(action: { 
                    if let onDismiss = onDismiss {
                        onDismiss()
                    } else {
                        dismiss()
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
            
            // Confetti particles overlay
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isEditingName) {
            NameEntrySheet(name: $draftName) { newName in
                let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                userName = trimmed
                draftName = trimmed
                isEditingName = false
            } onCancel: {
                draftName = userName
                isEditingName = false
            }
            .presentationDetents([.height(220)])
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showConfetti = true
            }
        }
    }
}

struct NameEntrySheet: View {
    @Binding var name: String
    var onSave: (String) -> Void
    var onCancel: () -> Void
    @FocusState private var isFieldFocused: Bool

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("What's your name?")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("Enter your name", text: $name)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .focused($isFieldFocused)
                .padding(14)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(12)

            HStack(spacing: 12) {
                Button("Cancel") {
                    onCancel()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.secondary.opacity(0.15))
                .foregroundColor(.primary)
                .cornerRadius(12)

                Button("Save") {
                    onSave(trimmedName)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(trimmedName.isEmpty ? Color.gray.opacity(0.3) : Color.white)
                .foregroundColor(.black)
                .cornerRadius(12)
                .disabled(trimmedName.isEmpty)
            }
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isFieldFocused = true
            }
        }
    }
}

struct ConfettiView: View {
    @State private var positions: [CGPoint] = []
    @State private var opacity: Double = 1
    
    let confettiEmojis = ["🎊", "✨", "🎈", "🌟", "🎯", "💚"]
    let numberOfParticles = 20
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<numberOfParticles, id: \.self) { index in
                Text(confettiEmojis[index % confettiEmojis.count])
                    .font(.system(size: CGFloat.random(in: 20...35)))
                    .position(
                        x: positions.indices.contains(index) ? positions[index].x : CGFloat.random(in: 0...geometry.size.width),
                        y: positions.indices.contains(index) ? positions[index].y : -50
                    )
                    .opacity(opacity)
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
                    .animation(
                        .linear(duration: 2.5)
                        .delay(Double.random(in: 0...0.5)),
                        value: positions
                    )
            }
        }
        .onAppear {
            withAnimation {
                positions = (0..<numberOfParticles).map { _ in
                    CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: UIScreen.main.bounds.height + 100
                    )
                }
            }
            
            withAnimation(.easeOut(duration: 2).delay(1)) {
                opacity = 0
            }
        }
    }
}

struct CheckInCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        CheckInCompletionView()
    }
}
