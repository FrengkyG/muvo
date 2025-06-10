//
//  OnboardingViewModel.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var isOnboardingCompleted: Bool {
        didSet {
            UserDefaults.standard.set(isOnboardingCompleted, forKey: Self.onboardingKey)
        }
    }

    private static let onboardingKey = "completedOnboarding"

    init() {
        self.isOnboardingCompleted = UserDefaults.standard.bool(forKey: Self.onboardingKey)
    }

    func markOnboardingAsCompleted() {
        isOnboardingCompleted = true
    }

    func resetOnboarding() {
        isOnboardingCompleted = false
    }
}
