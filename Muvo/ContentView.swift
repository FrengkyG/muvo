//
//  ContentView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import SwiftUI
import SwiftData


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

//struct ContentView: View {
//    @StateObject private var viewModel = OnboardingViewModel()
//    
//    var body: some View {
//        if viewModel.isOnboardingCompleted {
//            SentencePracticeView()
//        } else {
//            SentencePracticeView()
//
//        }
//
//    }
//}
