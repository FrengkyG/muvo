//
//  Helper.swift
//  Muvo
//
//  Created by Marcelinus Gerardo on 16/06/25.
//

func chunked<T>(_ array: [T], size: Int) -> [[T]] {
    stride(from: 0, to: array.count, by: size).map {
        Array(array[$0..<min($0 + size, array.count)])
    }
}
