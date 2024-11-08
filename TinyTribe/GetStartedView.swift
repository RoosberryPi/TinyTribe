//
//  ContentView.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 07/11/2024.
//

import SwiftUI


import SwiftUI

struct GetStartedView: View {
    var body: some View {
        VStack {
            Spacer()
            
            // App Logo or Icon
            Image(systemName: "person.3.fill") // Replace with actual app logo if available
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(ColorPalette.rustyRed)
                .padding(.bottom, 40)
            
            // Title
            Text("Welcome to TinyTribe")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.charcoalGray)
            
            // Subtitle
            Text("Babysit each other's children and build a stronger community.")
                .font(.headline)
                .foregroundColor(ColorPalette.warmTaupe)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)
            
            Spacer()
            
            // Get Started Button
            Button(action: {
                // Handle button action
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(ColorPalette.softCream)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(ColorPalette.rustyRed)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            // Additional Text
            Text("Already have an account? Log in")
                .font(.subheadline)
                .foregroundColor(ColorPalette.powderBlue)
                .padding(.top, 20)
            
            Spacer()
        }
        .background(ColorPalette.warmBeige)
        .edgesIgnoringSafeArea(.all)
    }
}

struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedView()
    }
}
