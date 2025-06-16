//
//  MainAppView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject var userViewModel = UserViewModel()
    @Environment(\.modelContext) private var context
    
    @Query var categories: [Category]
    @Query var questions: [Question]
    
    var body: some View {
        NavigationView{
            VStack(spacing: 24) {
                HStack {
                    Text("Hello, \(userViewModel.username)")
                    Spacer()
                }
                
                // Card
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(categories) { category in
                        NavigationLink(destination: WordCheckView()) {
                            progressCard(category: category)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                Spacer()
            }
            .padding()
        }
    }
    
    func progressCard(category: Category) -> some View {
        VStack(alignment: .leading) {
            Text(category.name)
                .font(.headline)
            ProgressView(value: category.completion) {
                Text("\(Int(category.completion * 100))% Done")
                    .font(.subheadline)
            }
            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
}
