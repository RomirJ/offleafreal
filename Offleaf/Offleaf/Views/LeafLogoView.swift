//
//  LeafLogoView.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI

struct LeafLogoView: View {
    var size: CGFloat = 120
    
    var body: some View {
        ZStack {
            // Create a simple teardrop/leaf shape using Path
            Path { path in
                let width = size * 0.8
                let height = size
                let offsetX = (size - width) / 2
                
                // Start from top center (pointed tip)
                path.move(to: CGPoint(x: size / 2, y: 0))
                
                // Left curve
                path.addCurve(
                    to: CGPoint(x: size / 2, y: height * 0.9),
                    control1: CGPoint(x: offsetX, y: height * 0.3),
                    control2: CGPoint(x: offsetX, y: height * 0.6)
                )
                
                // Right curve back to top
                path.addCurve(
                    to: CGPoint(x: size / 2, y: 0),
                    control1: CGPoint(x: size - offsetX, y: height * 0.6),
                    control2: CGPoint(x: size - offsetX, y: height * 0.3)
                )
            }
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.3, green: 0.8, blue: 0.4),
                        Color(red: 0.1, green: 0.6, blue: 0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Add veins on top
            Path { path in
                // Center vein
                path.move(to: CGPoint(x: size / 2, y: size * 0.1))
                path.addLine(to: CGPoint(x: size / 2, y: size * 0.8))
                
                // Side veins
                for i in 0..<5 {
                    let y = size * (0.25 + Double(i) * 0.1)
                    // Left vein
                    path.move(to: CGPoint(x: size / 2, y: y))
                    path.addLine(to: CGPoint(x: size * 0.3, y: y + size * 0.03))
                    // Right vein
                    path.move(to: CGPoint(x: size / 2, y: y))
                    path.addLine(to: CGPoint(x: size * 0.7, y: y + size * 0.03))
                }
            }
            .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
            
            // Stem
            Rectangle()
                .fill(Color(red: 0.15, green: 0.5, blue: 0.2))
                .frame(width: 3, height: size * 0.08)
                .offset(y: size * 0.45)
        }
        .frame(width: size, height: size)
    }
}

struct LeafLogoView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
        Color.black
            .ignoresSafeArea()
        LeafLogoView()
    }
}
}