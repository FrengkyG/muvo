//
//  Category.swift
//  Muvo
//
//  Created by Marcelinus Gerardo on 11/06/25.
//

import Foundation
import SwiftData

@Model
class Category: Identifiable {
    @Attribute(.unique) var id: String
    var name: String
    var questions: [Question] = []
    
    var completion: Double {
        guard !questions.isEmpty else { return 0.0 }
        let doneCount = questions.filter { $0.done }.count
        return Double(doneCount) / Double(questions.count)
    }
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
}
