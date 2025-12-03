//
//  AgePickerView.swift
//  Offleaf
//
//  Age picker with scroll and haptic feedback
//

import SwiftUI
import UIKit

struct AgePickerView: View {
    @Binding var selectedAge: Int
    @State private var lastHapticValue: Int = -1
    
    let minAge = 13
    let maxAge = 100
    
    private var ages: [Int] {
        Array(minAge...maxAge)
    }
    
    private let itemHeight: CGFloat = 60
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Selection indicator (green bar in center)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.15))
                        .frame(height: itemHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.3, green: 0.8, blue: 0.5), lineWidth: 2)
                        )
                        .padding(.horizontal, 40)
                        .allowsHitTesting(false)
                }
                
                // Custom scroll view with snapping
                AgeSnappingScrollView(
                    selectedAge: $selectedAge,
                    ages: ages,
                    itemHeight: itemHeight,
                    viewHeight: geometry.size.height
                )
                .onChange(of: selectedAge) { oldValue, newValue in
                    // Haptic feedback when value changes
                    if newValue != lastHapticValue {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        lastHapticValue = newValue
                    }
                }
                
                // Gradient overlays for fade effect
                VStack {
                    LinearGradient(
                        colors: [
                            Color.black,
                            Color.black.opacity(0.9),
                            Color.black.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: geometry.size.height * 0.3)
                    
                    Spacer()
                    
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.9),
                            Color.black
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: geometry.size.height * 0.3)
                }
                .allowsHitTesting(false)
            }
        }
    }
}

// UIKit-based snapping scroll view for precise control
struct AgeSnappingScrollView: UIViewRepresentable {
    @Binding var selectedAge: Int
    let ages: [Int]
    let itemHeight: CGFloat
    let viewHeight: CGFloat
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.backgroundColor = .clear
        
        // Create content view
        let contentView = UIView()
        contentView.backgroundColor = .clear
        
        // Add spacers and age labels
        let topSpacer = viewHeight / 2 - itemHeight / 2
        let bottomSpacer = viewHeight / 2 - itemHeight / 2
        let totalHeight = topSpacer + CGFloat(ages.count) * itemHeight + bottomSpacer
        
        contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: totalHeight)
        
        // Add age labels
        for (index, age) in ages.enumerated() {
            let label = UILabel()
            label.text = "\(age)"
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 36, weight: .medium)
            label.textColor = .white.withAlphaComponent(0.4)
            // Shift labels left by 15 points to center within the green box
            label.frame = CGRect(
                x: -15,
                y: topSpacer + CGFloat(index) * itemHeight,
                width: UIScreen.main.bounds.width,
                height: itemHeight
            )
            label.tag = age
            contentView.addSubview(label)
        }
        
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
        scrollView.contentInsetAdjustmentBehavior = .never
        
        // Store labels in coordinator for updating
        context.coordinator.labels = contentView.subviews.compactMap { $0 as? UILabel }
        context.coordinator.scrollView = scrollView
        context.coordinator.itemHeight = itemHeight
        context.coordinator.ages = ages
        context.coordinator.topSpacer = topSpacer
        
        // Scroll to initial position
        if let index = ages.firstIndex(of: selectedAge) {
            let offset = CGFloat(index) * itemHeight
            scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
        }
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // Update selection if changed externally
        if let index = ages.firstIndex(of: selectedAge) {
            let targetOffset = CGFloat(index) * itemHeight
            if abs(scrollView.contentOffset.y - targetOffset) > 1 {
                scrollView.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: true)
            }
        }
        
        // Update label appearances
        context.coordinator.updateLabelAppearances(selectedAge: selectedAge)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: AgeSnappingScrollView
        var labels: [UILabel] = []
        weak var scrollView: UIScrollView?
        var itemHeight: CGFloat = 60
        var ages: [Int] = []
        var topSpacer: CGFloat = 0
        var isScrolling = false
        var scrollTimer: Timer?
        
        init(parent: AgeSnappingScrollView) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Track that we're scrolling
            isScrolling = true
            
            // Cancel any existing timer
            scrollTimer?.invalidate()
            
            // Calculate current index for visual feedback only
            let offset = scrollView.contentOffset.y
            let index = Int(round(offset / itemHeight))
            let clampedIndex = max(0, min(ages.count - 1, index))
            let newAge = ages[clampedIndex]
            
            // Update label appearances for visual feedback
            updateLabelAppearances(selectedAge: newAge)
            
            // Don't update the binding while actively scrolling
            // Set a timer to update after scrolling stops
            scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
                self?.updateSelectionAfterScroll(scrollView)
            }
        }
        
        private func updateSelectionAfterScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.y
            let index = Int(round(offset / itemHeight))
            let clampedIndex = max(0, min(ages.count - 1, index))
            let newAge = ages[clampedIndex]
            
            // Update the binding
            if parent.selectedAge != newAge {
                parent.selectedAge = newAge
            }
            
            isScrolling = false
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            // Don't interfere with natural scrolling - let it flow naturally
            // We'll snap after it stops
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            // Scrolling has completely stopped
            scrollTimer?.invalidate()
            updateSelectionAfterScroll(scrollView)
            snapToNearestItem(scrollView)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                // User lifted finger and scroll stopped immediately (no momentum)
                scrollTimer?.invalidate()
                updateSelectionAfterScroll(scrollView)
                snapToNearestItem(scrollView)
            }
            // If decelerate is true, wait for scrollViewDidEndDecelerating
        }
        
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            // Ensure we're snapped after any animation
            scrollTimer?.invalidate()
            updateSelectionAfterScroll(scrollView)
        }
        
        private func snapToNearestItem(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.y
            let index = round(offset / itemHeight)
            let targetOffset = index * itemHeight
            
            // Only snap if we're not already aligned
            if abs(offset - targetOffset) > 0.5 {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    scrollView.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: false)
                }, completion: nil)
            }
        }
        
        func updateLabelAppearances(selectedAge: Int) {
            for label in labels {
                let isSelected = label.tag == selectedAge
                
                UIView.animate(withDuration: 0.2) {
                    if isSelected {
                        label.font = .systemFont(ofSize: 48, weight: .bold)
                        label.textColor = .white
                    } else {
                        label.font = .systemFont(ofSize: 36, weight: .medium)
                        label.textColor = .white.withAlphaComponent(0.4)
                    }
                }
            }
        }
    }
}

struct AgePickerView_Previews: PreviewProvider {
    static var previews: some View {
        AgePickerView(selectedAge: .constant(25))
            .background(Color.black)
    }
}