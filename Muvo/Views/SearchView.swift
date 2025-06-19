//
//  SearchView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 18/06/25.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var context
    @Query private var allQuestions: [Question]
    @State private var searchText: String = ""
    
    var filteredQuestions: [Question] {
            if searchText.isEmpty {
                return allQuestions
            } else {
                return allQuestions.filter {
                    $0.question.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    
    var body: some View {
        VStack {
            SearchNavigationView(searchText: $searchText).padding(.bottom, 16)
            HStack {
                Text("Semua")
                    .font(.custom("ApercuPro-Bold", size: 20))
                Image(systemName: "chevron.up.chevron.down")
                Spacer()
            }
            .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(filteredQuestions) { question in
                        HStack(alignment: .center, spacing: 16) {
                            Button(action: {}) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.orange)
                                    .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(question.question)
                                    .font(.custom("ApercuPro-Bold", size: 16))
                                    .foregroundColor(question.done ? .green : .black)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 2)
                    }
                }
                
            }
        }
        .padding(.horizontal, 24)
        .navigationBarHidden(true)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    SearchView()
}

struct SearchNavigationView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.black)
                TextField("Tulis kata yang mau kamu pelajari...", text: $searchText)
                    .font(.custom("ApercuPro", size: 14))
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}
