//
//  ContentView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        if viewModel.isOnboardingCompleted {
            HomeView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
