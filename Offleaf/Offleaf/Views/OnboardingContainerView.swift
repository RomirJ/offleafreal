//
//  OnboardingContainerView.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI

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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        currentScreen = .question1
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))

            case .question1:
                AssessmentQuestionView(
                    progress: 1.0 / 12.0,
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question2
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
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
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question3
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question1
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question3
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
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
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question4
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question2
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question4
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question2
                                }
                            }
                        }
                )
                
            case .question4:
                AssessmentQuestion4View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question5
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question3
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question5
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question3
                                }
                            }
                        }
                )
                
            case .question5:
                AssessmentQuestion5View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question6
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question4
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question6
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question4
                                }
                            }
                        }
                )
                
            case .question6:
                AssessmentQuestion6View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question7
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question5
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question7
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question5
                                }
                            }
                        }
                )
                
            case .question7:
                AssessmentQuestion7View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question8
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question6
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question8
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question6
                                }
                            }
                        }
                )
                
            case .question8:
                AssessmentQuestion8View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question9
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question7
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question9
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question7
                                }
                            }
                        }
                )
                
            case .question9:
                AssessmentQuestion9View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question10
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question8
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question10
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question8
                                }
                            }
                        }
                )
                
            case .question10:
                AssessmentQuestion10View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question11
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question9
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question11
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question9
                                }
                            }
                        }
                )
                
            case .question11:
                AssessmentQuestion11View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question12
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question10
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question12
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question10
                                }
                            }
                        }
                )
                
            case .question12:
                AssessmentQuestion12View(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .personalDetails
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question11
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question11
                                }
                            }
                        }
                )
                
            case .personalDetails:
                OnboardingPersonalDetailsView(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .awareness
                        }
                    },
                    onBack: {
                        isMovingForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .question12
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                // Swipe left to go forward
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .awareness
                                }
                            } else if value.translation.width > 50 {
                                // Swipe right to go back
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .question12
                                }
                            }
                        }
                )
                
            case .awareness:
                AwarenessScreen(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .findYourBestSelf
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .findYourBestSelf
                                }
                            } else if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .personalDetails
                                }
                            }
                        }
                )
                
            case .findYourBestSelf:
                FindYourBestSelfView(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .notificationPermission
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width > 50 {
                                isMovingForward = false
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    currentScreen = .awareness
                                }
                            } else if value.translation.width < -50 {
                                isMovingForward = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
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
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .calculatingPlan
                        }
                    },
                    onSkip: {
                        isMovingForward = true
                        // Save the quit date even if they skip notifications
                        quitDateString = ISO8601DateFormatter().string(from: Date())
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .calculatingPlan
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                
            case .calculatingPlan:
                CalculatingPlanView(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .socialProof
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
                
            case .socialProof:
                SocialProofRatingView(
                    onComplete: {
                        isMovingForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            currentScreen = .pricing
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))

            case .pricing:
                PricingView(
                    onComplete: completeOnboarding
                )
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading),
                    removal: .move(edge: isMovingForward ? .leading : .trailing)
                ))
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
