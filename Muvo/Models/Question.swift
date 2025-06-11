//
//  Question.swift
//  Muvo
//
//  Created by Marcelinus Gerardo on 11/06/25.
//

import Foundation
import SwiftData

@Model
class Question: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var question: String
    var done: Bool
    @Relationship var category: Category?

    init(id:String = UUID().uuidString, question: String, category: Category? = nil) {
        self.id = id
        self.question = question
        self.done = false
        self.category = category
    }
}
