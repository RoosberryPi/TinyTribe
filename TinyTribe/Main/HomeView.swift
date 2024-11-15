//
//  HomeView.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 08/11/2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            RequestsView()
                .tabItem {
                    Label("Requests", systemImage: "list.bullet")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .navigationBarBackButtonHidden(true) // Hide the back button
    }
}

#Preview {
    HomeView()
}

