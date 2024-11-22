//
//  ContentView.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 07/11/2024.
//

import SwiftUI


import SwiftUI

struct GetStartedView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Image("baby-boy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 40)
                
                Text("Welkom bij TinyTribe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.charcoalGray)
                
                Text("Om het allemaal wat makkelijker te maken")
                    .font(.headline)
                    .foregroundColor(ColorPalette.stoneGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 4)
                
                Spacer()
                
                // Get Started Button with Navigation
                NavigationLink(destination: RegisterView()) {
                    Text("Start")
                        .font(.headline)
                        .foregroundColor(ColorPalette.almostWhite)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ColorPalette.rustyRed)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                
                NavigationLink(destination: LoginView()) {
                    Text("Heb je al een account? Inloggen")
                        .font(.subheadline)
                        .foregroundColor(ColorPalette.midnightBlue)
                        .padding(.top, 20)
                }
                
                Spacer()
            }
            .background(ColorPalette.sand)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedView()
    }
}
