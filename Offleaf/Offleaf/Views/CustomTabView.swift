//
//  CustomTabView.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI

struct CustomTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // Home Tab
            TabBarButton(
                icon: "house.fill",
                text: "Home",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            // Learn Tab
            TabBarButton(
                icon: "book.fill",
                text: "Learn",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            // Progress Tab
            TabBarButton(
                icon: "chart.line.uptrend.xyaxis",
                text: "Progress",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
            
            // Profile Tab
            TabBarButton(
                icon: "person.fill",
                text: "Profile",
                isSelected: selectedTab == 3,
                action: { selectedTab = 3 }
            )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(white: 0.1).opacity(0.95))
                .overlay(
                    Capsule()
                        .stroke(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct TabBarButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.15))
                            .frame(width: 55, height: 28)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? Color(red: 0.3, green: 0.7, blue: 0.4) : Color.white.opacity(0.5))
                }
                .frame(height: 28)
                
                Text(text)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(red: 0.3, green: 0.7, blue: 0.4) : Color.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            CustomTabView(selectedTab: .constant(0))
    }
}
    }
}