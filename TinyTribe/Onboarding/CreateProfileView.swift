//
//  CreateProfileView.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 07/11/2024.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct CreateProfileView: View {
    @State private var profileImage: UIImage? = nil
    @State private var childImages: [UIImage] = []
    @State private var childNames: [String] = [""]
    @State private var isImagePickerPresented = false
    @State private var isChildImagePickerPresented = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Profile Image Picker
                VStack {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                    } else {
                        Button("Upload Profile Image") {
                            isImagePickerPresented.toggle()
                        }
                        .padding()
                        .background(ColorPalette.rustyRed)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                // Child Names and Photos
                ForEach(0..<childNames.count, id: \.self) { index in
                    VStack {
                        TextField("Child's Name", text: $childNames[index])
                            .padding()
                            .background(ColorPalette.almostWhite)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                        
                        Button("Upload Child Photo") {
                            isChildImagePickerPresented.toggle()
                        }
                        .padding()
                        .background(ColorPalette.rustyRed)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        if index < childImages.count, let childImage = childImages[index] {
                            Image(uiImage: childImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                        }
                    }
                }
                
                // Add Child Button
                Button("Add Another Child") {
                    childNames.append("")
                    childImages.append(UIImage())
                }
                .padding()
                .background(ColorPalette.rustyRed)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.top, 10)
                        .padding(.horizontal, 40)
                }
                
                // Create Profile Button
                Button(action: createProfile) {
                    Text("Create Profile")
                        .font(.headline)
                        .foregroundColor(ColorPalette.almostWhite)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ColorPalette.rustyRed)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .disabled(isLoading)
                
                Spacer()
            }
            .background(ColorPalette.sand)
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isImagePickerPresented, content: {
                ImagePicker(image: $profileImage)
            })
            .sheet(isPresented: $isChildImagePickerPresented, content: {
                ImagePicker(image: $childImages[childImages.count - 1])
            })
        }
    }
    
    // Create profile in Firebase
    func createProfile() {
        guard let profileImage = profileImage else {
            errorMessage = "Please upload a profile image."
            return
        }
        
        if childNames.contains(where: { $0.isEmpty }) || childImages.contains(where: { $0 == UIImage() }) {
            errorMessage = "Please provide names and photos for all children."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Upload Profile Image to Firebase Storage
        uploadImage(image: profileImage) { profileImageUrl in
            guard let profileImageUrl = profileImageUrl else {
                isLoading = false
                errorMessage = "Error uploading profile image."
                return
            }
            
            // Create Firebase User Profile Data
            var childrenData = [[String: Any]]()
            for i in 0..<childNames.count {
                uploadImage(image: childImages[i]) { childImageUrl in
                    if let childImageUrl = childImageUrl {
                        let childData = [
                            "name": childNames[i],
                            "imageUrl": childImageUrl
                        ]
                        childrenData.append(childData)
                    }
                    
                    // Once all images are uploaded, save the profile to Firestore
                    if childrenData.count == childNames.count {
                        saveProfile(profileImageUrl: profileImageUrl, childrenData: childrenData)
                    }
                }
            }
        }
    }
    
    func uploadImage(image: UIImage, completion: @escaping (String?) -> Void) {
        let imageData = image.jpegData(compressionQuality: 0.75)
        let storageRef = Storage.storage().reference().child("profileImages/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData!, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }
    
    func saveProfile(profileImageUrl: String, childrenData: [[String: Any]]) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser!.uid
        let profileData: [String: Any] = [
            "profileImageUrl": profileImageUrl,
            "children": childrenData
        ]
        
        db.collection("users").document(userId).setData(profileData) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Error saving profile: \(error.localizedDescription)"
            } else {
                // Successfully saved profile
                print("Profile created successfully!")
            }
        }
    }
}

struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProfileView()
    }
}
