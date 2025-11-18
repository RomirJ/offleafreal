//
//  ThinkingOfRelapsingView.swift
//  Offleaf
//
//  Created by Assistant on 10/16/25.
//

import SwiftUI

struct ThinkingOfRelapsingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingBreathe = false
    @State private var showingJournal = false
    @State private var showingContacts = false
    @State private var showingWalk = false
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
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
                    
                    Text("Don't Relapse")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Balance spacing
                    Color.clear
                        .frame(width: 60, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        // Warning message
                        VStack(spacing: 60) {
                            Text("Using cannabis can\nlead to:\nmemory problems,\nlack of motivation,\nand wasted potential.")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4))
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                            
                            Text("Every moment you\nstay clean is a\nstep towards\na better you.")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                        }
                        .padding(.top, 40)
                        .padding(.horizontal, 24)
                        
                        // Action buttons
                        VStack(spacing: 24) {
                            // Journal button
                            Button(action: { showingJournal = true }) {
                                HStack {
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 20, weight: .medium))
                                    Text("Journal Your Feelings")
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
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal, 24)
                            
                            // Call someone button
                            Button(action: { showingContacts = true }) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 20, weight: .medium))
                                    Text("Call Someone")
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
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal, 24)
                            
                            // Go for a walk button
                            Button(action: { showingWalk = true }) {
                                HStack {
                                    Image(systemName: "figure.walk")
                                        .font(.system(size: 20, weight: .medium))
                                    Text("Go for a Walk")
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
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Divider
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal, 40)
                        
                        // Breathing exercise button
                        Button(action: {
                            showingBreathe = true
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: "wind")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("Start Breathing Exercise")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
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
                            .cornerRadius(24)
                            .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 10, y: 4)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingBreathe) {
            BreatheView()
        }
        .fullScreenCover(isPresented: $showingJournal) {
            JournalFeatureView()
        }
        .fullScreenCover(isPresented: $showingContacts) {
            EmergencyContactsView()
        }
        .fullScreenCover(isPresented: $showingWalk) {
            WalkTrackerView()
        }
    }
}

struct ThinkingOfRelapsingView_Previews: PreviewProvider {
    static var previews: some View {
        ThinkingOfRelapsingView()
    }
}