//
//  MuvoApp.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import SwiftUI

@main
struct MuvoApp: App {
    @AppStorage("isFirstTimeLaunch") var isFirstTimeLaunch: Bool = true
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .modelContainer(Container.create(shouldCreateDefaults: &isFirstTimeLaunch))
    }
}
