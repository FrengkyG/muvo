//
//  OnboardingData.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import Foundation

struct OnboardingItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}
