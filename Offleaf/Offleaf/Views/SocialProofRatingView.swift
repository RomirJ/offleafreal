//
//  SocialProofRatingView.swift
//  Offleaf
//

import SwiftUI
import StoreKit

struct SocialProofRatingView: View {
    struct Testimonial: Identifiable {
        let id = UUID()
        let quote: String
        let name: String
        let handle: String
    }
    
    @State private var showContent = false
    @State private var currentIndex = 0
    @State private var hasRequestedReview = false
    @Environment(\.requestReview) var requestReview
    
    var onComplete: () -> Void
    
    private let testimonials: [Testimonial] = [
        Testimonial(
            quote: "Offleaf completely transformed my relationship with everyday habits. I finally feel in control of my life.",
            name: "Sarah M.",
            handle: "@sarahm23"
        ),
        Testimonial(
            quote: "The progress tracking and motivational notifications have kept me on track. I haven't relapsed in 3 months!",
            name: "Michael Stevens",
            handle: "@michaels"
        ),
        Testimonial(
            quote: "I was skeptical at first, but Offleaf's panic button feature has helped me resist countless temptations.",
            name: "Tony Coleman",
            handle: "@tcoleman23"
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Top spacing
                    Spacer().frame(height: 50)
                    
                    // Header
                    VStack(spacing: 16) {
                        Text("Love Offleaf?")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Stars with leaf icons
                        HStack(spacing: 6) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(red: 0.25, green: 0.75, blue: 0.4))
                                .rotationEffect(.degrees(-45))
                            
                            HStack(spacing: 3) {
                                ForEach(0..<5) { _ in
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.32))
                                        .font(.system(size: 26))
                                }
                            }
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(red: 0.25, green: 0.75, blue: 0.4))
                                .rotationEffect(.degrees(45))
                        }
                        
                        Text("This app was designed for people like you.")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                        
                        // User avatars - improved spacing
                        HStack(spacing: -10) {
                            ForEach(["SM", "MS", "TC"], id: \.self) { initials in
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Text(initials)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.9))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: 1.5)
                                    )
                            }
                            
                            Text("+ 20,000 people")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.65))
                                .padding(.leading, 18)
                        }
                        .padding(.top, 4)
                    }
                    
                    // Testimonials carousel
                    TabView(selection: $currentIndex) {
                        ForEach(Array(testimonials.enumerated()), id: \.element.id) { index, testimonial in
                            TestimonialCard(testimonial: testimonial)
                                .padding(.horizontal, 20)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 200)
                    .padding(.vertical, 10)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: showContent)
                    
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<testimonials.count, id: \.self) { idx in
                            Circle()
                                .fill(idx == currentIndex ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 7, height: 7)
                                .scaleEffect(idx == currentIndex ? 1.15 : 1.0)
                                .animation(.spring(response: 0.3), value: currentIndex)
                        }
                    }
                    
                    Spacer().frame(height: 20)
                    
                    // Action section
                    VStack(spacing: 16) {
                        Text("It's Time to Take Action")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Join thousands who've transformed\ntheir health with Offleaf")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                        
                        VStack(spacing: 12) {
                            // Main CTA - Request Review
                            Button(action: {
                                if !hasRequestedReview {
                                    hasRequestedReview = true
                                    // Request app store review
                                    DispatchQueue.main.async {
                                        requestReview()
                                    }
                                    // Continue after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        onComplete()
                                    }
                                } else {
                                    onComplete()
                                }
                            }) {
                                HStack {
                                    Text("Rate Offleaf")
                                        .font(.system(size: 18, weight: .semibold))
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.85, blue: 0.45),
                                            Color(red: 0.35, green: 0.75, blue: 0.4)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(27)
                                .padding(.horizontal, 24)
                            }
                            
                            // Skip option
                            Button(action: onComplete) {
                                Text("Maybe Later")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: showContent)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

private struct TestimonialCard: View {
    let testimonial: SocialProofRatingView.Testimonial
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 3) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.32))
                        .font(.system(size: 15))
                }
            }
            
            Text("\"\(testimonial.quote)\"")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.95))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(testimonial.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                Text(testimonial.handle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
            }
            .padding(.top, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

struct SocialProofRatingView_Previews: PreviewProvider {
    static var previews: some View {
        SocialProofRatingView(onComplete: {})
            .preferredColorScheme(.dark)
    }
}