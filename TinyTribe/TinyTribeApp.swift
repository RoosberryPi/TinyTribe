//
//  TinyTribeApp.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 07/11/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Colors application is starting up. ApplicationDelegate didFinishLaunchingWithOptions.")
        FirebaseApp.configure()
        return true
    }
}

@main
struct TinyTribeApp: App {
    @StateObject private var sessionManager = SessionManager()
    @State private var navigateToProfile = false  // Add a state variable to control navigation
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            VStack {
                if sessionManager.isLoggedIn {
                    if navigateToProfile {
                        ProfileView() // Navigate to ProfileView if URL is detected
                            .environmentObject(sessionManager)
                    } else {
                        HomeView() // Default to HomeView
                            .environmentObject(sessionManager)
                    }
                } else {
                    GetStartedView() // If not logged in, show the GetStartedView
                        .environmentObject(sessionManager)
                }
            }
            .onOpenURL { url in
                handleIncomingURL(url)
            }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let groupId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            print("Invalid URL or missing groupId")
            return
        }
        
        if let currentUser = Auth.auth().currentUser {
            // Check if the URL matches the condition to navigate to ProfileView
            navigateToProfile = true
            sessionManager.participateInGroup(groupId: groupId)
            print("Navigating to group \(groupId) for logged-in user \(currentUser.uid)")
        } else {
            // Handle unauthenticated user case
            sessionManager.pendingGroupId = groupId
            print("Prompting login for group \(groupId)")
        }
    }
}
