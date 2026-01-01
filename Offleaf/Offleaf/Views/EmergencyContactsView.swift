//
//  EmergencyContactsView.swift
//  Offleaf
//
//  Created by Assistant on 10/16/25.
//

import SwiftUI

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    let name: String
    let phone: String
    let isHelpline: Bool
    
    init(name: String, phone: String, isHelpline: Bool) {
        self.id = UUID()
        self.name = name
        self.phone = phone
        self.isHelpline = isHelpline
    }
}

class ContactsManager: ObservableObject {
    @Published var contacts: [EmergencyContact] = []
    
    private let saveKey = "EmergencyContacts"
    
    // Default helplines
    let defaultHelplines = [
        EmergencyContact(name: "SAMHSA National Helpline", phone: "1-800-662-4357", isHelpline: true),
        EmergencyContact(name: "Crisis Text Line", phone: "Text HOME to 741741", isHelpline: true),
        EmergencyContact(name: "Marijuana Anonymous", phone: "1-800-766-6779", isHelpline: true)
    ]
    
    init() {
        loadContacts()
    }
    
    func loadContacts() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                let decoded = try JSONDecoder().decode([EmergencyContact].self, from: data)
                contacts = decoded
            } catch {
                // Data corrupted - try to recover
                print("[EmergencyContacts] ERROR: Failed to decode contacts: \(error)")
                
                // Attempt recovery from backup
                if let backupData = UserDefaults.standard.data(forKey: "\(saveKey)_backup"),
                   let backupContacts = try? JSONDecoder().decode([EmergencyContact].self, from: backupData) {
                    contacts = backupContacts
                    save() // Re-save to main key
                } else {
                    // Use defaults but keep corrupted data for debugging
                    UserDefaults.standard.set(data, forKey: "\(saveKey)_corrupted")
                    contacts = defaultHelplines
                    save()
                }
            }
        } else {
            // First time - add default helplines
            contacts = defaultHelplines
            save()
        }
    }
    
    func addContact(_ contact: EmergencyContact) {
        contacts.append(contact)
        save()
    }
    
    func deleteContact(_ contact: EmergencyContact) {
        contacts.removeAll { $0.id == contact.id }
        save()
    }
    
    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let encoded = try encoder.encode(contacts)
            
            // Create backup before overwriting
            if let existingData = UserDefaults.standard.data(forKey: saveKey) {
                UserDefaults.standard.set(existingData, forKey: "\(saveKey)_backup")
            }
            
            // Save new data
            UserDefaults.standard.set(encoded, forKey: saveKey)
            
            // Verify save succeeded
            if UserDefaults.standard.data(forKey: saveKey) == nil {
                print("[EmergencyContacts] CRITICAL: Failed to save contacts to UserDefaults")
            }
        } catch {
            print("[EmergencyContacts] CRITICAL: Failed to encode contacts: \(error)")
            // Keep existing data rather than losing everything
        }
    }
    
    func callContact(_ contact: EmergencyContact) {
        // Check if this is Crisis Text Line
        if contact.name == "Crisis Text Line" || contact.phone.contains("741741") {
            // Open SMS with pre-filled message
            if let url = URL(string: "sms:741741&body=HOME") {
                UIApplication.shared.open(url)
            }
        } else {
            // Regular phone call
            let cleanedNumber = contact.phone.replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
            
            if let url = URL(string: "tel://\(cleanedNumber)") {
                UIApplication.shared.open(url)
            }
        }
    }
}

struct EmergencyContactsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var contactsManager = ContactsManager()
    @State private var showingAddContact = false
    @State private var showingCallConfirmation = false
    @State private var selectedContact: EmergencyContact?
    @State private var animateGradient = false
    @State private var showContent = false
    @State private var floatingAnimation = false
    
    // Helper functions for alert
    func getAlertTitle() -> String {
        if selectedContact?.name == "Crisis Text Line" {
            return "Text Crisis Text Line?"
        }
        return "Call \(selectedContact?.name ?? "")?"
    }
    
    func getActionButtonText() -> String {
        if selectedContact?.name == "Crisis Text Line" {
            return "Text"
        }
        return "Call"
    }
    
    func getAlertMessage() -> String {
        if selectedContact?.name == "Crisis Text Line" {
            return "You're about to open messages to text 741741"
        }
        return "You're about to call \(selectedContact?.phone ?? "")"
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Vibrant background orb
            BackgroundOrbView(animating: $floatingAnimation)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with glass morphism
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 24, weight: .medium))
                            Text("Back")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: { showingAddContact = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                            Text("Add")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.7, blue: 0.4),
                                    Color(red: 0.25, green: 0.6, blue: 0.35)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 8, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Hero message with glass card
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3),
                                                Color(red: 0.2, green: 0.6, blue: 0.3).opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .blur(radius: 10)
                                    .scaleEffect(floatingAnimation ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: floatingAnimation)
                                
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 36, weight: .medium))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(floatingAnimation ? 5 : -5))
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floatingAnimation)
                            }
                            
                            Text("Reach Out for Support")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("You're not alone. Connect with someone who cares.")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 32)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(.ultraThinMaterial.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.2),
                                                    Color.white.opacity(0.05)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .padding(.horizontal, 20)
                        .scaleEffect(showContent ? 1 : 0.9)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showContent)
                        
                        // Helplines section with enhanced design
                        if !contactsManager.contacts.filter({ $0.isHelpline }).isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "heart.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4))
                                    Text("24/7 Helplines")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                
                                VStack(spacing: 12) {
                                    ForEach(Array(contactsManager.contacts.filter { $0.isHelpline }.enumerated()), id: \.element.id) { index, contact in
                                        EnhancedContactCard(
                                            contact: contact,
                                            index: index,
                                            showContent: showContent,
                                            onCall: {
                                                selectedContact = contact
                                                showingCallConfirmation = true
                                            },
                                            onDelete: {
                                                // Don't allow deleting helplines
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Personal contacts section with enhanced design
                        let personalContacts = contactsManager.contacts.filter { !$0.isHelpline }
                        if !personalContacts.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "person.2.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1))
                                    Text("Your Support Network")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                
                                VStack(spacing: 12) {
                                    ForEach(Array(personalContacts.enumerated()), id: \.element.id) { index, contact in
                                        EnhancedContactCard(
                                            contact: contact,
                                            index: index + 3,
                                            showContent: showContent,
                                            onCall: {
                                                selectedContact = contact
                                                showingCallConfirmation = true
                                            },
                                            onDelete: {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                    contactsManager.deleteContact(contact)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        if personalContacts.isEmpty {
                            // Enhanced empty state
                            Button(action: { showingAddContact = true }) {
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.4, green: 0.7, blue: 1).opacity(0.2),
                                                        Color(red: 0.3, green: 0.6, blue: 0.9).opacity(0.1)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 100, height: 100)
                                            .blur(radius: 20)
                                        
                                        Image(systemName: "person.badge.plus")
                                            .font(.system(size: 40, weight: .medium))
                                            .foregroundColor(.white)
                                            .scaleEffect(floatingAnimation ? 1.1 : 0.9)
                                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floatingAnimation)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("Build Your Support Network")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("Add trusted friends and family")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20))
                                        Text("Add First Contact")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.7, blue: 1),
                                                Color(red: 0.3, green: 0.6, blue: 0.9)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(24)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 32)
                                        .fill(.ultraThinMaterial.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 32)
                                                .strokeBorder(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.white.opacity(0.2),
                                                            Color.white.opacity(0.05)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                            }
                            .padding(.horizontal, 20)
                            .scaleEffect(showContent ? 1 : 0.9)
                            .opacity(showContent ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateGradient = true
                showContent = true
                floatingAnimation = true
            }
        }
        .sheet(isPresented: $showingAddContact) {
            AddContactView { name, phone in
                let contact = EmergencyContact(name: name, phone: phone, isHelpline: false)
                contactsManager.addContact(contact)
            }
        }
        .alert(getAlertTitle(), isPresented: $showingCallConfirmation) {
            Button(getActionButtonText(), role: .destructive) {
                if let contact = selectedContact {
                    contactsManager.callContact(contact)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(getAlertMessage())
        }
    }
}

// Enhanced contact card with avatars and better design
struct EnhancedContactCard: View {
    let contact: EmergencyContact
    let index: Int
    let showContent: Bool
    let onCall: () -> Void
    let onDelete: () -> Void
    @State private var isPressed = false
    
    var avatarGradient: LinearGradient {
        if contact.isHelpline {
            return LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.7, blue: 0.4),
                    Color(red: 0.2, green: 0.6, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.6, blue: 1),
                    Color(red: 0.3, green: 0.5, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var initials: String {
        let words = contact.name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        } else if !words.isEmpty {
            return String(words[0].prefix(2))
        }
        return "?"
    }
    
    var body: some View {
        Button(action: onCall) {
            HStack(spacing: 16) {
                // Avatar with initials
                ZStack {
                    Circle()
                        .fill(avatarGradient)
                        .frame(width: 56, height: 56)
                    
                    if contact.isHelpline {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    } else {
                        Text(initials)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
                
                // Contact info
                VStack(alignment: .leading, spacing: 6) {
                    Text(contact.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "phone")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                        Text(contact.phone)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Call button
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isPressed ? [
                                    Color(red: 0.3, green: 0.7, blue: 0.4),
                                    Color(red: 0.25, green: 0.6, blue: 0.35)
                                ] : [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isPressed ? .white : Color(red: 0.3, green: 0.7, blue: 0.4))
                        .rotationEffect(.degrees(isPressed ? 15 : 0))
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial.opacity(0.15))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1) {} onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
        .contextMenu {
            if !contact.isHelpline {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .scaleEffect(showContent ? 1 : 0.8)
        .opacity(showContent ? 1 : 0)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.7)
            .delay(Double(index) * 0.05 + 0.2),
            value: showContent
        )
    }
}

// Background orb view
struct BackgroundOrbView: View {
    @Binding var animating: Bool
    
    var body: some View {
        ZStack {
            // Large golden orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3),
                            Color(red: 0.25, green: 0.6, blue: 0.35).opacity(0.2),
                            Color(red: 0.2, green: 0.5, blue: 0.3).opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 350, height: 350)
                .blur(radius: 30)
                .position(x: UIScreen.main.bounds.width - 80, y: 200)
                .rotationEffect(.degrees(animating ? 360 : 0))
                .animation(.linear(duration: 60).repeatForever(autoreverses: false), value: animating)
            
            // Smaller blue accent orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.4, green: 0.6, blue: 1).opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 20)
                .position(x: 100, y: UIScreen.main.bounds.height - 200)
                .scaleEffect(animating ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animating)
        }
    }
}

struct AddContactView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (String, String) -> Void
    
    @State private var name = ""
    @State private var phone = ""
    @FocusState private var focusedField: Field?
    @State private var animateGradient = false
    
    enum Field {
        case name, phone
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.2).opacity(0.5),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced header
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onSave(name, phone)
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(name.isEmpty || phone.isEmpty ? .white.opacity(0.3) : .white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: name.isEmpty || phone.isEmpty ? [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.08)
                                    ] : [
                                        Color(red: 0.3, green: 0.7, blue: 0.4),
                                        Color(red: 0.25, green: 0.6, blue: 0.35)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(
                                color: name.isEmpty || phone.isEmpty ? .clear : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3),
                                radius: 8,
                                y: 2
                            )
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Title section
                        VStack(spacing: 12) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1))
                                .scaleEffect(animateGradient ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateGradient)
                            
                            Text("Add Support Contact")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Someone you trust when times get tough")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        // Input fields with enhanced design
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                    Text("Contact Name")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                TextField("", text: $name, prompt: Text("Friend's name").foregroundColor(.white.opacity(0.3)))
                                    .foregroundColor(.white)
                                    .font(.system(size: 17, weight: .medium))
                                    .focused($focusedField, equals: .name)
                                    .padding(18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial.opacity(0.15))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(
                                                        focusedField == .name ?
                                                        Color(red: 0.4, green: 0.7, blue: 1).opacity(0.5) :
                                                        Color.white.opacity(0.1),
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                    Text("Phone Number")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                TextField("", text: $phone, prompt: Text("Phone number").foregroundColor(.white.opacity(0.3)))
                                    .foregroundColor(.white)
                                    .font(.system(size: 17, weight: .medium))
                                    .keyboardType(.phonePad)
                                    .focused($focusedField, equals: .phone)
                                    .padding(18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial.opacity(0.15))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(
                                                        focusedField == .phone ?
                                                        Color(red: 0.4, green: 0.7, blue: 1).opacity(0.5) :
                                                        Color.white.opacity(0.1),
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Privacy note
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.7))
                            Text("Contacts are stored securely on your device")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 10)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            focusedField = .name
            withAnimation(.easeInOut(duration: 1)) {
                animateGradient = true
            }
        }
    }
}

struct EmergencyContactsView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyContactsView()
    }
}