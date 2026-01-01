//
//  PersonalInformationView.swift
//  Offleaf
//

import SwiftUI

struct PersonalInformationView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userName") private var userName = ""
    @AppStorage("quitDate") private var quitDateString = ""
    @AppStorage("smokeFrequency") private var smokeFrequencyRaw = CannabisUseFrequency.unknown.rawValue
    @AppStorage("weeklySpending") private var weeklySpending: Double = 0
    
    @State private var editedName: String = ""
    @State private var editedQuitDate: Date = Date()
    @State private var editedFrequency: CannabisUseFrequency = .unknown
    @State private var editedSpending: String = ""
    @State private var hasChanges = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Personal Information")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: saveChanges) {
                        Text("Save")
                            .foregroundColor(hasChanges ? Color(red: 0.3, green: 0.7, blue: 0.4) : .white.opacity(0.3))
                    }
                    .disabled(!hasChanges)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            TextField("Enter your name", text: $editedName)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .tint(.white)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                )
                                .onChange(of: editedName) { _, _ in checkForChanges() }
                        }
                        
                        // Quit Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quit Date")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            DatePicker("", selection: $editedQuitDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .onChange(of: editedQuitDate) { _, _ in checkForChanges() }
                        }
                        
                        // Smoking Frequency
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Previous Smoking Frequency")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Menu {
                                ForEach(CannabisUseFrequency.assessmentOptions, id: \.self) { option in
                                    Button(option.assessmentLabel) {
                                        editedFrequency = option
                                        checkForChanges()
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(editedFrequency == .unknown ? "Select frequency" : editedFrequency.summaryLabel)
                                        .font(.system(size: 16))
                                        .foregroundColor(editedFrequency == .unknown ? .white.opacity(0.5) : .white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                )
                            }
                        }
                        
                        // Weekly Spending
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weekly Spending on Cannabis")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                TextField("0", text: $editedSpending)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .tint(.white)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: editedSpending) { _, newValue in 
                                        let sanitized = sanitizeSpendingInput(newValue)
                                        if sanitized != newValue {
                                            editedSpending = sanitized
                                        }
                                        checkForChanges()
                                    }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                            )
                        }
                        
                        // Info Box
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
                            
                            Text("This information helps us personalize your quit journey and track your progress.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.4, green: 0.6, blue: 1).opacity(0.1))
                        )
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            loadCurrentValues()
        }
    }
    
    private func loadCurrentValues() {
        editedName = userName
        editedFrequency = CannabisUseFrequency(storedValue: smokeFrequencyRaw)
        editedSpending = String(format: "%.0f", weeklySpending)
        
        if !quitDateString.isEmpty,
           let date = ISO8601DateFormatter().date(from: quitDateString) {
            editedQuitDate = date
        }
    }
    
    private func checkForChanges() {
        let spendingValue = Double(editedSpending) ?? 0
        let originalDate = ISO8601DateFormatter().date(from: quitDateString) ?? Date()
        
        hasChanges = editedName != userName ||
                    editedFrequency.rawValue != smokeFrequencyRaw ||
                    spendingValue != weeklySpending ||
                    !Calendar.current.isDate(editedQuitDate, inSameDayAs: originalDate)
    }
    
    private func saveChanges() {
        // Validate and clean name - don't allow empty
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        userName = trimmedName.isEmpty ? "Friend" : trimmedName
        
        smokeFrequencyRaw = editedFrequency.rawValue
        // Validate spending amount - must be reasonable range
        let spendingAmount = Double(editedSpending) ?? 0
        let maxWeeklySpending = 5000.0
        weeklySpending = min(max(0, spendingAmount), maxWeeklySpending) // $0-$5000/week
        
        // Validate quit date - can't be in future
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: editedQuitDate)
        let validatedQuitDate = selectedDate > today ? today : editedQuitDate
        quitDateString = ISO8601DateFormatter().string(from: validatedQuitDate)
        
        dismiss()
    }
    
    private func sanitizeSpendingInput(_ value: String) -> String {
        // Remove any non-numeric characters except decimal point
        var result = ""
        var hasDecimal = false
        var decimalPlaces = 0
        
        for char in value {
            if char.isNumber {
                if hasDecimal {
                    decimalPlaces += 1
                    if decimalPlaces <= 2 { // Limit to 2 decimal places
                        result.append(char)
                    }
                } else {
                    result.append(char)
                }
            } else if char == "." && !hasDecimal {
                hasDecimal = true
                result.append(char)
            }
        }
        
        // Validate range (max $5000/week)
        if let amount = Double(result), amount > 5000 {
            return "5000"
        }
        
        return result
    }
}

struct PersonalInformationView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalInformationView()
    }
}
