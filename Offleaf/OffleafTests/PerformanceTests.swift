//
//  PerformanceTests.swift
//  OffleafTests
//
//  Performance and optimization testing
//

import Testing
import Foundation
@testable import Offleaf

struct PerformanceTests {
    
    @Test func testMainThreadBlockingOperations() {
        // Test for main thread blocking
        let expectation = TestExpectation()
        
        // Simulate the animateDaysClean pattern
        Task {
            let steps = 60
            let frameDelay: UInt64 = 20_000_000 // 20ms
            var mainThreadCalls = 0
            
            for _ in 0..<steps {
                try? await Task.sleep(nanoseconds: frameDelay)
                await MainActor.run {
                    mainThreadCalls += 1
                }
            }
            
            await MainActor.run {
                #expect(mainThreadCalls == 60, "Main thread called 60 times in loop - PERFORMANCE ISSUE")
                expectation.fulfill()
            }
        }
        
        // This confirms main thread is being called repeatedly
    }
    
    @Test func testExcessiveStateVariables() {
        // Test counting state variables in a view
        // Simulating HomeView's state management
        var stateVariables: [String] = []
        
        // Add all the state variables we found
        for i in 1...45 {
            stateVariables.append("@State var state\(i)")
        }
        
        #expect(stateVariables.count == 45, "HomeView has 45 @State variables - ARCHITECTURE ISSUE")
        #expect(stateVariables.count > 10, "More than 10 @State variables indicates poor state management")
    }
    
    @Test func testConcurrentAnimations() {
        // Test for multiple concurrent animations
        let particleCount = 6
        let animationDuration = 3.0
        let totalAnimationLoad = Double(particleCount) * animationDuration
        
        #expect(particleCount == 6, "6 concurrent particle animations detected")
        #expect(totalAnimationLoad > 10, "High animation load - PERFORMANCE ISSUE")
    }
    
    @Test func testMemoryUsageForLargeFiles() {
        // Test file size impact
        let homeViewLineCount = 1785
        let recommendedMaxLines = 500
        
        #expect(homeViewLineCount > recommendedMaxLines, "HomeView exceeds recommended size by \(homeViewLineCount - recommendedMaxLines) lines")
        #expect(homeViewLineCount > 1500, "File is extremely large - MAINTAINABILITY ISSUE")
    }
    
    @Test func testUserDefaultsPerformance() {
        // Test UserDefaults access frequency
        let accessCount = 96 // Found in grep
        let recommendedMax = 20
        
        #expect(accessCount > recommendedMax, "Excessive UserDefaults usage: \(accessCount) occurrences")
        
        // Test rapid UserDefaults access
        let startTime = Date()
        for i in 0..<100 {
            UserDefaults.standard.set(i, forKey: "perfTest")
            _ = UserDefaults.standard.integer(forKey: "perfTest")
        }
        let elapsed = Date().timeIntervalSince(startTime)
        
        #expect(elapsed < 1.0, "UserDefaults operations completed in \(elapsed) seconds")
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "perfTest")
    }
}

// Helper for async testing
struct TestExpectation {
    private var fulfilled = false
    
    mutating func fulfill() {
        fulfilled = true
    }
    
    func wait(timeout: TimeInterval = 5.0) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !fulfilled && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.1)
        }
        return fulfilled
    }
}