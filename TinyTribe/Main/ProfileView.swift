//
//  ProfileView.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 15/11/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager // Access sessionManager if needed

    var body: some View {
        VStack {
            Text("Profile")
                .font(.largeTitle)
                .padding()

            Button(action: {
                sessionManager.logOut() // Log out and return to GetStartedView
            }) {
                Text("Log Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
            Spacer()
        }
    }
}

#Preview {
    ProfileView()
}
