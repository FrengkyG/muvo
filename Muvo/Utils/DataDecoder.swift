//
//  DataDecoder.swift
//  Muvo
//
//  Created by Marcelinus Gerardo on 11/06/25.
//

import Foundation

struct CategoryJSON: Decodable {
    let id: String
    let name: String
}

struct QuestionJSON: Decodable {
    let question: String
    let categoryId: String
}

enum CategoryJSONDecoder {
    static func decode(from fileName: String) -> [CategoryJSON] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([CategoryJSON].self, from: data) else {
            print("Failed to load or decode \(fileName).json")
            return []
        }
        return decoded
    }
}

enum QuestionJSONDecoder {
    static func decode(from fileName: String) -> [QuestionJSON] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([QuestionJSON].self, from: data) else {
            print("Failed to load or decode \(fileName).json")
            return []
        }
        return decoded
    }
}
