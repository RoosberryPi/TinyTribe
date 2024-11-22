//
//  LoginView.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 07/11/2024.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @EnvironmentObject var sessionManager: SessionManager

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var userLoggedIn = false
    @State private var isLoggingIn = false
    @State private var showWelcomeMessage = false
    @State private var babyPositionBottom: CGFloat = -300 // Initial position of the first baby (below text)
    @State private var babyPositionTop: CGFloat = UIScreen.main.bounds.width + 300 // Initial position of the second baby (above text)
    
    var body: some View {
        ZStack {
            ColorPalette.sand
                .edgesIgnoringSafeArea(.all)
            
            if userLoggedIn {
                VStack(spacing: 50) {
                    if showWelcomeMessage {
                        
                        Image("baby-boy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 100)
                            .offset(x: babyPositionBottom)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 8.0)) {
                                    babyPositionBottom = UIScreen.main.bounds.width / 2 + 150
                                }
                            }
                            .onChange(of: babyPositionBottom) { newValue in
                                if newValue == UIScreen.main.bounds.width / 2 + 150 {
                                    // Trigger the second baby after the first baby disappears
                                    withAnimation(Animation.easeInOut(duration: 8.0)) {
                                        babyPositionTop = -UIScreen.main.bounds.width / 2 - 150
                                    }
                                }
                            }
                        
                        Text("Welkom terug!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ColorPalette.charcoalGray)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                            .animation(.easeIn(duration: 0.5), value: showWelcomeMessage)
                        
                        Image("baby-boy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 100)
                            .scaleEffect(x: -1, y: 1) // Flips the image horizontally
                            .offset(x: babyPositionTop)
                    }
                    
                    NavigationLink(destination: HomeView()) {
                        Text("Ga verder")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(ColorPalette.rustyRed)
                            .cornerRadius(10)
                            .padding(.horizontal, 30)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Inloggen")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.charcoalGray)
                        .padding(.bottom, 20)
                    
                    // Email TextField
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
                    
                    // Password TextField
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
                    
                    // Login Button
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
                    Spacer()
                    Spacer()
                }
            }
        }
    }
    
    func loginUser() {
        // Validate inputs
        if email.isEmpty || password.isEmpty {
            errorMessage = "Alle velden moeten ingevuld zijn."
        } else {
            errorMessage = ""
            isLoggingIn = true
            
            // Login via Firebase
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                isLoggingIn = false
                
                if let error = error {
                    errorMessage = "Inloggen mislukt: \(error.localizedDescription)"
                } else {
                    userLoggedIn = true
                    
                    withAnimation {
                        showWelcomeMessage = true
                    }
                    
                    if let app = UIApplication.shared.delegate as? AppDelegate {
                        sessionManager.isLoggedIn = true
                    }
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
