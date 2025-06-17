//
//  UserViewModel.swift
//  Muvo
//
//  Created by Frengky Gunawan on 12/06/25.
//

import Foundation

class UserViewModel: ObservableObject {
    private static let usernameKey = "username"

    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: Self.usernameKey)
        }
    }

    init() {
        self.username = UserDefaults.standard.string(forKey: Self.usernameKey) ?? "Guest"
    }

    func saveUsername(_ name: String) {
        self.username = name
    }

    func getUsername() -> String {
        UserDefaults.standard.string(forKey: Self.usernameKey) ?? "Guest"
    }
}
