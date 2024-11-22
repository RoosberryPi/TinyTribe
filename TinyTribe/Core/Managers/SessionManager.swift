//
//  SessionManager.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 15/11/2024.
//

import Combine
import FirebaseAuth

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var selectedGroupId: String?
    @Published var pendingGroupId: String?

    init() {
        checkUserSession()
    }
    
    func participateInGroup(groupId: String) {
          // Update state to navigate the user to the specific group
          self.selectedGroupId = groupId
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
            selectedGroupId = nil
            pendingGroupId = nil
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
    }
}
