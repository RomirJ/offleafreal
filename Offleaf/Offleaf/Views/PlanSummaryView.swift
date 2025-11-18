//
//  PlanSummaryView.swift
//  Offleaf
//

import SwiftUI

struct PlanSummaryView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("quitDate") private var quitDateString = ""
    @AppStorage("smokeFrequency") private var smokeFrequencyRaw = CannabisUseFrequency.unknown.rawValue
    @AppStorage("weeklySpending") private var weeklySpending: Double = 0
    
    private var quitDate: Date? {
        guard !quitDateString.isEmpty else { return nil }
        return ISO8601DateFormatter().date(from: quitDateString)
    }
    
    private var currentWeek: Int {
        guard let quitDate = quitDate else { return 1 }
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: quitDate, to: Date()).weekOfYear ?? 0
        return max(1, weeks + 1)
    }
    
    @ViewBuilder
    var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Text("Close")
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text("Your Plan")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear.frame(width: 50)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 5)
    }
    
    @ViewBuilder
    var weekProgressView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                
                Text("Week \(currentWeek)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Stay strong! Every day counts.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    var focusAreasView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Focus Areas This Week")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                FocusItem(icon: "brain.head.profile", text: "Practice mindful breathing daily", color: Color(red: 0.4, green: 0.6, blue: 1))
                FocusItem(icon: "figure.walk", text: "Take a walk when cravings hit", color: Color(red: 0.3, green: 0.7, blue: 0.4))
                FocusItem(icon: "heart.fill", text: "Remember your reasons for quitting", color: Color(red: 0.9, green: 0.3, blue: 0.3))
                FocusItem(icon: "trophy.fill", text: "Celebrate small victories", color: Color(red: 0.9, green: 0.7, blue: 0.3))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    @ViewBuilder
    var journeyProgressView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Journey")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            if let quitDate = quitDate {
                InfoRow(label: "I will be sober by", value: quitDate.formatted(date: .abbreviated, time: .omitted))
            }
            let frequency = CannabisUseFrequency(storedValue: smokeFrequencyRaw)
            InfoRow(label: "Previous Frequency", value: frequency.summaryLabel)
            InfoRow(label: "Money Saving", value: String(format: "$%.0f/week", weeklySpending))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    @ViewBuilder
    var motivationalQuoteView: some View {
        VStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
            
            Text("The secret of change is to focus all of your energy not on fighting the old, but on building the new.")
                .font(.system(size: 16))
                .italic()
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("- Socrates")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    var scrollContent: some View {
        VStack(spacing: 24) {
            weekProgressView
            focusAreasView
            journeyProgressView
            motivationalQuoteView
            Spacer(minLength: 40)
        }
        .padding(.horizontal, 20)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    scrollContent
                }
            }
        }
    }
}

struct FocusItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct PlanSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        PlanSummaryView()
    }
}
