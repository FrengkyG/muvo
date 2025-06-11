//
//  ExampleView.swift
//  Muvo
//
//  Created by Marcelinus Gerardo on 11/06/25.
//

import SwiftUI
import SwiftData

struct ExampleView: View {
    @Environment(\.modelContext) private var context
    
    @Query private var categories: [Category]
    @Query private var questions: [Question]
    
    @State private var selectedQuestion: Question?

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Kategori")
                    .font(.title2)
                    .bold()
                
                ForEach(categories) { category in
                    VStack(alignment: .leading) {
                        Text(category.name)
                            .font(.headline)
                        ProgressView(value: category.completion) {
                            Text("\(Int(category.completion * 100))% selesai")
                                .font(.subheadline)
                        }
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Pilih Pertanyaan")
                    .font(.title3)
                
                Picker("Pertanyaan", selection: $selectedQuestion) {
                    ForEach(questions) { question in
                        Text(question.question)
                            .tag(Optional(question)) // Optional wrapping needed
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            if let question = selectedQuestion {
                Button {
                    question.done.toggle()
                    try? context.save()
                } label: {
                    Text(question.done ? "Tandai Belum Selesai" : "Tandai Selesai")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(question.done ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .animation(.default, value: question.done)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ExampleView()
        .modelContainer(for: [Category.self, Question.self], inMemory: true)
}
