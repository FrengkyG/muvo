//
//  Container.swift
//  Muvo
//
//  Created by Marcelinus Gerardo on 11/06/25.
//

import Foundation
import SwiftData

actor Container {
    @MainActor
    static func create(shouldCreateDefaults: inout Bool) -> ModelContainer {
        var categoryMap: [String: Category] = [:]
        let schema = Schema([Category.self, Question.self])
        let configuration = ModelConfiguration()
        let container: ModelContainer

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        if shouldCreateDefaults {
            let categories = CategoryJSONDecoder.decode(from: "categories")
            if categories.isEmpty == false {
                categories.forEach { c in
                    let categoryObject = Category(id: c.id, name: c.name)
                    container.mainContext.insert(categoryObject)
                    categoryMap[c.id] = categoryObject
                    print("Category inserted: \(categoryObject.name), ID: \(categoryObject.id)")
                }
            }

            let questions = QuestionJSONDecoder.decode(from: "questions")
            if questions.isEmpty == false {
                questions.forEach { q in
                    guard let category = categoryMap[q.categoryId] else {
                        print("Error: Category not found for Question: \(q.question)")
                        return
                    }
                    let questionObject = Question(
                        question: q.question,
                        category: category
                    )
                    category.questions.append(questionObject)
                    container.mainContext.insert(questionObject)
                    print("Question inserted: \(questionObject.question)")
                }
            }

            shouldCreateDefaults = false
        }

        return container
    }
}
