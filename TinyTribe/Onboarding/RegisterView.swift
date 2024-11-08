//
//  RegisterView.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 07/11/2024.
//

import SwiftUI
import Firebase

struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isRegistering = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Text("Maak een account aan")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.charcoalGray)
                    .padding(.bottom, 20)
                
                // Name TextField with clear button inside
                ZStack(alignment: .trailing) {
                    TextField("Naam", text: $name)
                        .padding()
                        .background(ColorPalette.almostWhite)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                    
                    if !name.isEmpty {
                        Button(action: {
                            name = "" // Clear the text field
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 40)
                    }
                }
                
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
                        .padding(.top, 10)
                        .padding(.horizontal, 40)
                }
                
                // Register Button
                Button(action: {
                    // Validate inputs
                    if name.isEmpty || email.isEmpty || password.isEmpty {
                        errorMessage = "Alle velden moeten ingevuld zijn."
                    } else if !email.contains("@") {
                        errorMessage = "Voer een geldige e-mail in."
                    } else if password.count < 6 {
                        errorMessage = "Het wachtwoord moet minimaal 6 tekens lang zijn."
                    } else {
                        errorMessage = "" // Clear error message if validation passes
                        isRegistering = true
                        
                        // Register user via Firebase
                        Auth.auth().createUser(withEmail: email, password: password) { result, error in
                            isRegistering = false
                            
                            if let error = error {
                                errorMessage = "Registratie mislukt: \(error.localizedDescription)"
                            } else {
                                // Successfully registered
                                print("User registered successfully!")
                            }
                        }
                    }
                }) {
                    if isRegistering {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.almostWhite))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(ColorPalette.rustyRed)
                            .cornerRadius(10)
                    } else {
                        Text("Registreer")
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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
