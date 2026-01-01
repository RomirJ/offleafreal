//
//  CustomTabView.swift
//  Offleaf
//
//  Minimal liquid glass tab bar
//

import SwiftUI

struct CustomTabView: View {
    @Binding var selectedTab: Int
    @State private var selectedPosition: CGFloat = 0
    @State private var liquidBulge: CGFloat = 0
    @State private var dragLocation: CGPoint? = nil
    
    let tabs = [
        (icon: "house.fill", text: "Home"),
        (icon: "book.fill", text: "Learn"),
        (icon: "chart.line.uptrend.xyaxis", text: "Progress"),
        (icon: "person.fill", text: "Profile")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let tabWidth = geometry.size.width / CGFloat(tabs.count)
            
            ZStack {
                // Ultra minimal glass background
                Capsule()
                    .fill(Color.white.opacity(0.01))
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial.opacity(0.05))
                    )
                
                // Subtle liquid morph effect
                Canvas { context, size in
                    let selectedX = selectedPosition
                    
                    var path = Path()
                    let baseY = size.height * 0.5
                    
                    path.move(to: CGPoint(x: 0, y: baseY))
                    
                    for x in stride(from: 0, to: size.width, by: 3) {
                        let distanceToSelected = abs(x - selectedX)
                        let influence = max(0, 1 - distanceToSelected / (tabWidth * 0.8))
                        
                        let bulge = influence * 12 * (1 + liquidBulge * 0.5)
                        let y = baseY - bulge
                        
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.addLine(to: CGPoint(x: 0, y: size.height))
                    path.closeSubpath()
                    
                    context.fill(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [
                                Color(red: 0.1, green: 0.5, blue: 0.3).opacity(0.02),
                                Color.clear
                            ]),
                            startPoint: CGPoint(x: selectedX, y: 0),
                            endPoint: CGPoint(x: selectedX, y: size.height)
                        )
                    )
                }
                
                // Tab buttons
                HStack(spacing: 0) {
                    ForEach(tabs.indices, id: \.self) { index in
                        TabButton(
                            icon: tabs[index].icon,
                            text: tabs[index].text,
                            isSelected: selectedTab == index,
                            onTap: {
                                selectedTab = index
                                withAnimation(.easeOut(duration: 0.2)) {
                                    liquidBulge = 1.0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        liquidBulge = 0
                                    }
                                }
                            }
                        )
                        .frame(width: tabWidth)
                    }
                }
                
                // Magnifying glass effect on drag - now visible!
                if let location = dragLocation {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.9, blue: 0.5).opacity(0.3),
                                    Color(red: 0.1, green: 0.7, blue: 0.4).opacity(0.15),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                        .blur(radius: 0.5)
                        .position(location)
                        .allowsHitTesting(false)
                        .animation(.easeOut(duration: 0.1), value: location)
                }
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    let tabWidth = geometry.size.width / CGFloat(tabs.count)
                    selectedPosition = CGFloat(newValue) * tabWidth + tabWidth / 2
                }
            }
            .onAppear {
                let tabWidth = geometry.size.width / CGFloat(tabs.count)
                selectedPosition = CGFloat(selectedTab) * tabWidth + tabWidth / 2
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Update drag location for magnifying glass
                        dragLocation = value.location
                        
                        // Calculate which tab is being touched - using correct geometry width
                        let tabWidth = geometry.size.width / CGFloat(tabs.count)
                        let index = Int(value.location.x / tabWidth)
                        
                        // Update selection if dragging over a new tab
                        if index >= 0 && index < tabs.count && index != selectedTab {
                            selectedTab = index
                            
                            // Trigger liquid bulge effect on drag
                            withAnimation(.easeOut(duration: 0.15)) {
                                liquidBulge = 1.5
                            }
                        }
                    }
                    .onEnded { _ in
                        // Reset effects when drag ends
                        withAnimation(.easeOut(duration: 0.2)) {
                            dragLocation = nil
                            liquidBulge = 0
                        }
                    }
            )
        }
        .frame(height: 65)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

struct TabButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: isSelected ? 24 : 20, 
                                 weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? 
                        Color(red: 0.2, green: 0.9, blue: 0.5) : 
                        Color.white.opacity(0.3))
                    .scaleEffect(isPressed ? 0.9 : (isSelected ? 1.1 : 1.0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                
                Text(text)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? 
                        Color(red: 0.2, green: 0.9, blue: 0.5).opacity(0.8) : 
                        Color.white.opacity(0.25))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity,
                           pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
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