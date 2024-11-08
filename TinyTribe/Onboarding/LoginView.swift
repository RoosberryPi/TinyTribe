//
//  LoginView.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 07/11/2024.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var userLoggedIn = false
    @State private var isLoggingIn = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                if userLoggedIn {
                    Text("Welkom bij TinyTribe!")
                        .font(.largeTitle)
                        .foregroundColor(ColorPalette.charcoalGray)
                        .padding()
                } else {
                    Text("Inloggen")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.charcoalGray)
                        .padding(.bottom, 20)
                    
                    // Email TextField with clear button inside
                    ZStack(alignment: .trailing) {
                        TextField("E-mail", text: $email)
                            .padding()
                            .background(ColorPalette.almostWhite)
                            .cornerRadius(10)
                            .padding(.horizontal, 30)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
                        
                        if !email.isEmpty {
                            Button(action: {
                                email = "" // Clear the text field
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 40)
                        }
                    }
                    
                    // Password TextField with clear button inside
                    ZStack(alignment: .trailing) {
                        SecureField("Wachtwoord", text: $password)
                            .padding()
                            .background(ColorPalette.almostWhite)
                            .cornerRadius(10)
                            .padding(.horizontal, 30)
                        
                        if !password.isEmpty {
                            Button(action: {
                                password = "" // Clear the text field
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 40)
                        }
                    }
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal, 40)
                    }
                    
                    // Login Button with spinner
                    Button(action: loginUser) {
                        if isLoggingIn {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.almostWhite))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(ColorPalette.rustyRed)
                                .cornerRadius(10)
                        } else {
                            Text("Inloggen")
                                .font(.headline)
                                .foregroundColor(ColorPalette.almostWhite)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(ColorPalette.rustyRed)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    NavigationLink(destination: RegisterView()) {
                        Text("Heb je nog geen account? Registreer")
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.midnightBlue)
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
            .background(ColorPalette.sand)
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func loginUser() {
        // Validate inputs
        if email.isEmpty || password.isEmpty {
            errorMessage = "Alle velden moeten ingevuld zijn."
        } else {
            errorMessage = "" // Clear error message if validation passes
            isLoggingIn = true
            
            // Login actie via Firebase
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                isLoggingIn = false
                
                if let error = error {
                    errorMessage = "Inloggen mislukt: \(error.localizedDescription)"
                } else {
                    userLoggedIn = true
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

