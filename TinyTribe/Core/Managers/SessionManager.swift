//
//  File.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 15/11/2024.
//

import Combine
import FirebaseAuth

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        checkUserSession()
    }

    func checkUserSession() {
        if let user = Auth.auth().currentUser {
            print("User \(user.email ?? "Unknown") is logged in.")
            isLoggedIn = true
        } else {
            print("No user is logged in.")
            isLoggedIn = false
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
    }
}
