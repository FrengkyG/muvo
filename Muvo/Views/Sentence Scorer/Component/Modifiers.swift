//
//  Modifiers.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI

// MARK: - View Modifiers
struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("ApercuPro-Bold", size: 18))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue)
            .cornerRadius(25)
    }
}

struct SecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("ApercuPro-Bold", size: 18))
            .fontWeight(.bold)
            .foregroundColor(Color("primaryblue"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.blue, lineWidth: 2)
            )
    }
}

