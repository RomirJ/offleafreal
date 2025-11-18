//
//  MedicalReferencesView.swift
//  Offleaf
//
//  Medical and Scientific References
//

import SwiftUI

struct MedicalReferencesView: View {
    @Environment(\.dismiss) var dismiss
    
    let references = [
        MedicalReference(
            category: "Cannabis Withdrawal & Cravings",
            citations: [
                Citation(
                    title: "Magnitude and duration of cue-induced craving",
                    journal: "Drug and Alcohol Dependence",
                    year: "2016",
                    url: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5113710/"
                ),
                Citation(
                    title: "Cannabis withdrawal in chronic users",
                    journal: "American Journal of Addiction",
                    year: "2014",
                    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC3986824/"
                )
            ]
        ),
        MedicalReference(
            category: "Sleep Disruption",
            citations: [
                Citation(
                    title: "Sleep Disturbance in Heavy Marijuana Users",
                    journal: "Sleep",
                    year: "2008",
                    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC2442418/"
                ),
                Citation(
                    title: "Sleep disturbance during cannabis withdrawal",
                    journal: "Drug and Alcohol Dependence",
                    year: "2011",
                    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC3119729/"
                )
            ]
        ),
        MedicalReference(
            category: "THC Metabolism & Clearance",
            citations: [
                Citation(
                    title: "Chemistry, Metabolism, and Toxicology of Cannabis",
                    journal: "Iranian Journal of Psychiatry",
                    year: "2012",
                    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC3570572/"
                ),
                Citation(
                    title: "Reintoxication: Release of fat-stored THC",
                    journal: "British Journal of Pharmacology",
                    year: "2009",
                    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC2782342/"
                )
            ]
        ),
        MedicalReference(
            category: "Breathing Techniques & Stress",
            citations: [
                Citation(
                    title: "The Effect of Diaphragmatic Breathing",
                    journal: "Frontiers in Psychology",
                    year: "2017",
                    url: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5455070/"
                ),
                Citation(
                    title: "Breathing practices for treatment of psychiatric disorders",
                    journal: "Journal of Alternative and Complementary Medicine",
                    year: "2013",
                    url: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4104929/"
                )
            ]
        ),
        MedicalReference(
            category: "Exercise & Mental Health",
            citations: [
                Citation(
                    title: "The Benefits of Exercise for the Clinically Depressed",
                    journal: "The Primary Care Companion",
                    year: "2004",
                    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC474733/"
                ),
                Citation(
                    title: "The impact of exercise on depression",
                    journal: "Current Sports Medicine Reports",
                    year: "2024",
                    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC11298280/"
                )
            ]
        ),
        MedicalReference(
            category: "Cognitive Effects",
            citations: [
                Citation(
                    title: "Long-Term Cannabis Use and Cognitive Reserves",
                    journal: "American Journal of Psychiatry",
                    year: "2022",
                    url: "https://psychiatryonline.org/doi/10.1176/appi.ajp.2021.21060664"
                ),
                Citation(
                    title: "Cannabis use and cognitive dysfunction",
                    journal: "Indian Journal of Psychiatry",
                    year: "2011",
                    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC3221171/"
                )
            ]
        ),
        MedicalReference(
            category: "Respiratory Effects",
            citations: [
                Citation(
                    title: "Marijuana and Lung Health",
                    journal: "American Lung Association",
                    year: "2023",
                    url: "https://www.lung.org/quit-smoking/smoking-facts/health-effects/marijuana-and-lung-health"
                ),
                Citation(
                    title: "Effect of cannabis smoking on lung function",
                    journal: "npj Primary Care Respiratory Medicine",
                    year: "2016",
                    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC5072387/"
                )
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
                            
                            Text("Medical References")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Scientific sources for health information in this app")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Disclaimer
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
                                
                                Text("Medical Disclaimer")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
                            }
                            
                            Text("This app provides general health information for educational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always consult qualified healthcare providers for medical concerns.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        // Reference Categories
                        ForEach(references) { reference in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(reference.category)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                ForEach(reference.citations) { citation in
                                    CitationCard(citation: citation)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Footer
                        VStack(spacing: 12) {
                            Text("Last Updated: November 2024")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("References are periodically reviewed and updated")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct MedicalReference: Identifiable {
    let id = UUID()
    let category: String
    let citations: [Citation]
}

struct Citation: Identifiable {
    let id = UUID()
    let title: String
    let journal: String
    let year: String
    let url: String
}

struct CitationCard: View {
    let citation: Citation
    
    var body: some View {
        Link(destination: URL(string: citation.url)!) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(citation.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text("\(citation.journal) (\(citation.year))")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
}

struct MedicalReferencesView_Previews: PreviewProvider {
    static var previews: some View {
        MedicalReferencesView()
    }
}