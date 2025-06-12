//
//  MainAppView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var userViewModel = UserViewModel()

    var body: some View {
        VStack {
            Text("Hello, \(userViewModel.username)")
        }
    }
}

#Preview {
    ContentView()
}
