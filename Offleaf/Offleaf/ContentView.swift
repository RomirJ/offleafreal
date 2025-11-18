//
//  ContentView.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding { 
            HomeView()
                .onAppear {
                    // Clear any reset flag on app launch
                    UserDefaults.standard.set(false, forKey: "justResetCounter")
                }
        } else {
            OnboardingContainerView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
