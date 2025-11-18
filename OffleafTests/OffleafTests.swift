//
//  OffleafTests.swift
//  OffleafTests
//
//  Created by Romir Jain on 10/10/25.
//

import Testing
@testable import Offleaf

struct CannabisUseFrequencyTests {

    @Test func initializesFromStoredValues() {
        #expect(CannabisUseFrequency(storedValue: "weekly") == .oneToTwoPerWeek)
        #expect(CannabisUseFrequency(storedValue: "Every day, once or twice") == .dailyOnceOrTwice)
        #expect(CannabisUseFrequency(storedValue: "unknown") == .unknown)
    }

    @Test func estimatedHoursScaleMonotonic() {
        let ordered: [CannabisUseFrequency] = [.oneToTwoPerWeek, .threeToFourPerWeek, .fiveToSixPerWeek, .dailyOnceOrTwice, .dailyMultiple]
        let hours = ordered.map { $0.estimatedHoursPerDay }
        let isStrictlyIncreasing = zip(hours, hours.dropFirst()).allSatisfy { $0 < $1 }
        #expect(isStrictlyIncreasing)
    }
}
