//
//  OnboardingContainerView.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI
import UIKit

struct OnboardingContainerView: View {
    @State private var currentScreen: OnboardingScreen = .welcome
    @State private var isMovingForward = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("quitDate") private var quitDateString = ""
    
    enum OnboardingScreen {
        case welcome
        case question1
        case question2
        case question3
        case question4
        case question5
        case question6
        case question7
        case question8
        case question9
        case question10
        case question11
        case question12
        case personalDetails
        case awareness
        case findYourBestSelf
        case notificationPermission
        case calculatingPlan
        case socialProof
        case pricing
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            switch currentScreen {
            case .welcome:
                WelcomeScreenView(onNext: {
                    isMovingForward = true
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        currentScreen = .question1
                    }
                })
                .transition(.asymmetric(
                    insertion: .scale(scale: 1.1).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))

            case .question1:
                AssessmentQuestionView(
                    progress: 1.0 / 12.0,
                    onComplete: {
                        isMovingForward = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                currentScreen = .question2
                            }
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question2
                                }
                            }
                        }
                )
                
            case .question2:
                AssessmentQuestion2View(
                    progress: 2.0 / 12.0,
                    onComplete: {
                        isMovingForward = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                currentScreen = .question3
                            }
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                            currentScreen = .question1
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading).combined(with: .opacity),
                    removal: .move(edge: isMovingForward ? .leading : .trailing).combined(with: .opacity)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question3
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question1
                                }
                            }
                        }
                )
                
            case .question3:
                AssessmentQuestion3View(
                    progress: 3.0 / 12.0,
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question4
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question2
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question4
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question2
                                }
                            }
                        }
                )
                
            case .question4:
                AssessmentQuestion4View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question5
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question3
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question5
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question3
                                }
                            }
                        }
                )
                
            case .question5:
                AssessmentQuestion5View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question6
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question4
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question6
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question4
                                }
                            }
                        }
                )
                
            case .question6:
                AssessmentQuestion6View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question7
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question5
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question7
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question5
                                }
                            }
                        }
                )
                
            case .question7:
                AssessmentQuestion7View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question8
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question6
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question8
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question6
                                }
                            }
                        }
                )
                
            case .question8:
                AssessmentQuestion8View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question9
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question7
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question9
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question7
                                }
                            }
                        }
                )
                
            case .question9:
                AssessmentQuestion9View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question10
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question8
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question10
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question8
                                }
                            }
                        }
                )
                
            case .question10:
                AssessmentQuestion10View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question11
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question9
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question11
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question9
                                }
                            }
                        }
                )
                
            case .question11:
                AssessmentQuestion11View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question12
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question10
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question12
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question10
                                }
                            }
                        }
                )
                
            case .question12:
                AssessmentQuestion12View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .personalDetails
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .question11
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question11
                                }
                            }
                        }
                )
                
            case .personalDetails:
                OnboardingPersonalDetailsView(
                    onComplete: {
                        isMovingForward = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            currentScreen = .awareness
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                            currentScreen = .question12
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 1.05).combined(with: .opacity)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                // Swipe left to go forward
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .awareness
                                }
                            } else if value.translation.width > 50 {
                                // Swipe right to go back
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .question12
                                }
                            }
                        }
                )
                
            case .awareness:
                AwarenessScreen(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .findYourBestSelf
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .findYourBestSelf
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .personalDetails
                                }
                            }
                        }
                )
                
            case .findYourBestSelf:
                FindYourBestSelfView(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .notificationPermission
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .awareness
                                }
                            } else if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentScreen = .notificationPermission
                                }
                            }
                        }
                )
                
            case .notificationPermission:
                NotificationPermissionView(
                    onComplete: {
                        isMovingForward = true
                        // Save the quit date when moving to plan calculation
                        quitDateString = ISO8601DateFormatter().string(from: Date())
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .calculatingPlan
                        }
                    },
                    onSkip: {
                        isMovingForward = true
                        // Save the quit date even if they skip notifications
                        quitDateString = ISO8601DateFormatter().string(from: Date())
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .calculatingPlan
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                
            case .calculatingPlan:
                CalculatingPlanView(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .socialProof
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                
            case .socialProof:
                SocialProofRatingView(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .pricing
                        }
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))

            case .pricing:
                PricingView(
                    onComplete: completeOnboarding
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
            }
        }
    }
    
    private func completeOnboarding() {
        isMovingForward = true
        // Quit date is already set in notification permission step
        // Schedule initial notifications if permission was granted
        Task {
            await NotificationManager.shared.scheduleInitialNotifications()
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView()
    }
}
