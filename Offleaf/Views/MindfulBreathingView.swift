//
//  MindfulBreathingView.swift
//  Offleaf
//
//  Created by Assistant on 10/19/25.
//

import SwiftUI

struct MindfulBreathingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTechnique: String? = nil
    
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
                    
                    LeafLogoView(size: 40)
                    
                    Text("Learn")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Title
                        VStack(spacing: 12) {
                            Text("Mindful Breathing")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Your brain's natural reset button")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                        
                        // The Science Behind It
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
                                
                                Text("The Neuroscience")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Controlled breathing activates the parasympathetic nervous system through vagus nerve stimulation¹. Research shows mindful breathing can:")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                BenefitRow(icon: "arrow.down", text: "Help reduce cortisol (stress hormone) levels²", color: Color(red: 0.3, green: 0.7, blue: 0.4))
                                BenefitRow(icon: "brain", text: "Support prefrontal cortex function", color: Color(red: 0.4, green: 0.6, blue: 1))
                                BenefitRow(icon: "heart.fill", text: "Lower heart rate and blood pressure³", color: Color(red: 0.9, green: 0.3, blue: 0.3))
                                BenefitRow(icon: "sparkles", text: "Support natural mood regulation", color: Color(red: 0.9, green: 0.7, blue: 0.3))
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 24)
                        
                        // Breathing Techniques
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Proven Techniques")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                // 4-7-8 Technique
                                TechniqueCard(
                                    name: "4-7-8 Breathing",
                                    subtitle: "Dr. Andrew Weil's sleep technique",
                                    description: "Inhale for 4, hold for 7, exhale for 8. This technique stimulates the vagus nerve and promotes relaxation⁴.",
                                    effectiveness: "Research-backed anxiety reduction technique",
                                    icon: "moon.zzz.fill",
                                    color: Color(red: 0.4, green: 0.6, blue: 0.9),
                                    isExpanded: selectedTechnique == "478"
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedTechnique = selectedTechnique == "478" ? nil : "478"
                                    }
                                }
                                
                                // Box Breathing
                                TechniqueCard(
                                    name: "Box Breathing",
                                    subtitle: "Navy SEAL technique",
                                    description: "4 counts in, 4 hold, 4 out, 4 hold. Used by military and first responders for stress management⁵.",
                                    effectiveness: "Proven technique for focus and calm",
                                    icon: "square",
                                    color: Color(red: 0.3, green: 0.7, blue: 0.4),
                                    isExpanded: selectedTechnique == "box"
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedTechnique = selectedTechnique == "box" ? nil : "box"
                                    }
                                }
                                
                                // Wim Hof Method
                                TechniqueCard(
                                    name: "Wim Hof Method",
                                    subtitle: "Controlled hyperventilation",
                                    description: "30 deep breaths followed by breath retention. Increases oxygen delivery and may support endorphin release⁶.",
                                    effectiveness: "May enhance mood and energy",
                                    icon: "wind",
                                    color: Color(red: 0.3, green: 0.8, blue: 0.8),
                                    isExpanded: selectedTechnique == "wim"
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedTechnique = selectedTechnique == "wim" ? nil : "wim"
                                    }
                                }
                                
                                // 3-3-3 Quick Reset
                                TechniqueCard(
                                    name: "3-3-3 Quick Reset",
                                    subtitle: "Emergency craving buster",
                                    description: "3 seconds in, 3 seconds hold, 3 seconds out. Quick technique to interrupt craving patterns⁷.",
                                    effectiveness: "Rapid intervention for cravings",
                                    icon: "bolt.fill",
                                    color: Color(red: 0.9, green: 0.7, blue: 0.3),
                                    isExpanded: selectedTechnique == "333"
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedTechnique = selectedTechnique == "333" ? nil : "333"
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // When to Use
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                                
                                Text("Perfect Moments to Practice")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                MomentRow(time: "Morning", description: "Start your day grounded instead of reaching for substances")
                                MomentRow(time: "Craving hits", description: "Interrupt the urge-action cycle immediately")
                                MomentRow(time: "Before sleep", description: "Replace nighttime habits with calming breath")
                                MomentRow(time: "Stressful moments", description: "Your portable stress-relief tool")
                                MomentRow(time: "3pm slump", description: "Natural energy boost without substances")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.1))
                        )
                        .padding(.horizontal, 24)
                        
                        // Pro Tips
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
                                
                                Text("Pro Tips")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ProTipRow(text: "Breathe through your nose - it activates more calming receptors")
                                ProTipRow(text: "Place one hand on chest, one on belly - belly should move more")
                                ProTipRow(text: "Count in your native language - it engages more brain regions")
                                ProTipRow(text: "Pair with a mantra like 'This too shall pass'")
                                ProTipRow(text: "Start with just 1 minute - consistency beats duration")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.1))
                        )
                        .padding(.horizontal, 24)
                        
                        // Call to Action
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                            
                            Text("Ready to try?")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Set a reminder to practice one technique today. Your future self will thank you.")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.15),
                                            Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 24)
                        
                        // Medical References Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Scientific References")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                MindfulCitationLink(number: "1", text: "Parasympathetic Nervous System Activation", url: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5455070/")
                                MindfulCitationLink(number: "2", text: "Breathing and Cortisol Reduction", url: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5455070/")
                                MindfulCitationLink(number: "3", text: "Heart Rate Variability and Breathing", url: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4104929/")
                                MindfulCitationLink(number: "4", text: "4-7-8 Breathing Technique", url: "https://www.healthline.com/health/4-7-8-breathing")
                                MindfulCitationLink(number: "5", text: "Box Breathing Research", url: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5455070/")
                                MindfulCitationLink(number: "6", text: "Breathing and Endorphins", url: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6137615/")
                                MindfulCitationLink(number: "7", text: "Breathing for Craving Management", url: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2725024/")
                            }
                            
                            Text("Information provided is for educational purposes. Consult healthcare providers for medical advice.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                                .italic()
                                .padding(.top, 8)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct MindfulCitationLink: View {
    let number: String
    let text: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 4) {
                Text("[\(number)]")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
                Text(text)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
                    .underline()
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 10))
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
            }
        }
    }
}

struct TechniqueCard: View {
    let name: String
    let subtitle: String
    let description: String
    let effectiveness: String
    let icon: String
    let color: Color
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 12))
                                .foregroundColor(color)
                            
                            Text(effectiveness)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(color)
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isExpanded ? 0.08 : 0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isExpanded ? color.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct MomentRow: View {
    let time: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(time)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                .frame(width: 80, alignment: .leading)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct ProTipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct MindfulBreathingView_Previews: PreviewProvider {
    static var previews: some View {
        MindfulBreathingView()
    }
}