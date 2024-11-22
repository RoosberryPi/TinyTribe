//
//  ProfileView.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 15/11/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreInternal

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var groups: [Group] = []
    @State private var showInviteSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack {
            Text("Profile")
                .font(.largeTitle)
                .padding()

            // Groups Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Groups")
                    .font(.headline)
                    .padding(.leading)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if groups.isEmpty {
                    Text("You are not part of any groups yet.")
                        .foregroundColor(.gray)
                        .padding(.leading)
                } else {
                    // List of groups with invitees
                    List(groups) { group in
                        VStack(alignment: .leading) {
                            Text(group.name ?? "Unnamed Group")
                                .font(.headline)

                            ForEach(group.members) { member in
                                HStack {
                                    Text(member.email)
                                        .font(.subheadline)

                                    Spacer()

                                    if member.hasAccepted {
                                        Text("Accepted")
                                            .foregroundColor(.green)
                                    } else {
                                        Text("Pending")
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            
                            // Share Link Button
                            Button(action: {
                                shareGroupLink(groupId: group.id)
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up.fill")
                                    Text("Share Group Link")
                                }
                                .font(.subheadline)
                                .padding()
                                .foregroundColor(.white)
                                .background(ColorPalette.midnightBlue)
                                .cornerRadius(8)
                            }
                            .padding(.top)
                        }
                        .padding(.vertical)
                    }
                }

                // Invite Button
                Button(action: {
                    showInviteSheet = true
                }) {
                    Text("Invite to Group")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ColorPalette.midnightBlue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(10)
            .padding()

            Spacer()

            // Log Out Button
            Button(action: {
                sessionManager.logOut()
            }) {
                Text("Log Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(ColorPalette.rustyRed)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteView { groupName, contacts in
                createGroupAndSendInvites(groupName: groupName, contacts: contacts)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Group Invitation"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            loadGroups()
        }
    }

    // Example function to generate group link
    func generateGroupLink(groupId: String) -> String {
        return "tinytribe://group?id=\(groupId)"
    }
    
    // Function to share the link via UIActivityViewController
    func shareGroupLink(groupId: String) {
        let link = generateGroupLink(groupId: groupId)
        let activityViewController = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        
        // Present the share sheet
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }

    func createGroupAndSendInvites(groupName: String, contacts: [String]) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        isLoading = true
        
        // Create a new group document
        let newGroupRef = db.collection("groups").document()
        let invitees = contacts.map { Member(email: $0, hasAccepted: false) }
        let groupData: [String: Any] = [
            "name": groupName,
            "members": [currentUserId],
            "invitees": invitees.map { ["email": $0.email, "hasAccepted": $0.hasAccepted] },
            "createdAt": FieldValue.serverTimestamp()
        ]

        newGroupRef.setData(groupData) { error in
            if let error = error {
                isLoading = false
                alertMessage = "Failed to create group: \(error.localizedDescription)"
                showAlert = true
                return
            }

            // Update user's groups
            let userRef = db.collection("users").document(currentUserId)
            userRef.getDocument { document, error in
                if let document = document, document.exists {
                    userRef.updateData([
                        "groups": FieldValue.arrayUnion([newGroupRef.documentID])
                    ]) { error in
                        handleGroupUpdateCompletion(error: error, groupRef: newGroupRef, invitees: invitees)
                    }
                } else {
                    userRef.setData([
                        "groups": [newGroupRef.documentID]
                    ]) { error in
                        handleGroupUpdateCompletion(error: error, groupRef: newGroupRef, invitees: invitees)
                    }
                }
            }
        }
    }

    private func handleGroupUpdateCompletion(error: Error?, groupRef: DocumentReference, invitees: [Member]) {
        isLoading = false
        if let error = error {
            alertMessage = "Failed to update user groups: \(error.localizedDescription)"
            showAlert = true
            return
        }

        alertMessage = "Group created successfully! Invites sent."
        showAlert = true
        groups.append(Group(id: groupRef.documentID, name: groupRef.documentID, members: invitees))
    }

    func loadGroups() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(currentUserId).getDocument { snapshot, error in
            if let error = error {
                alertMessage = "Failed to load groups: \(error.localizedDescription)"
                showAlert = true
                return
            }

            if let data = snapshot?.data(), let groupIds = data["groups"] as? [String] {
                fetchGroupDetails(groupIds: groupIds)
            }
        }
    }

    private func fetchGroupDetails(groupIds: [String]) {
        let db = Firestore.firestore()

        db.collection("groups").whereField(FieldPath.documentID(), in: groupIds).getDocuments { snapshot, error in
            if let error = error {
                alertMessage = "Failed to load group details: \(error.localizedDescription)"
                showAlert = true
                return
            }

            self.groups = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                let invitees = (data["invitees"] as? [[String: Any]])?.compactMap {
                    Member(email: $0["email"] as? String ?? "", hasAccepted: $0["hasAccepted"] as? Bool ?? false)
                } ?? []
                return Group(id: doc.documentID, name: data["name"] as? String ?? "", members: invitees)
            } ?? []
        }
    }
}


#Preview {
    ProfileView()
}


#Preview {
    ProfileView()
}

struct GroupDetailView: View {
    let groupId: String
    @State private var group: Group?
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Group...")
            } else if let group = group {
                Text(group.name ?? "Unnamed Group")
                    .font(.largeTitle)
                    .padding()

                List(group.members) { member in
                    HStack {
                        Text(member.email)
                        Spacer()
                        Text(member.hasAccepted ? "Accepted" : "Pending")
                            .foregroundColor(member.hasAccepted ? .green : .orange)
                    }
                }

                Button(action: joinGroup) {
                    Text("Join Group")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ColorPalette.sageGreen)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            } else {
                Text("Group not found.")
            }
        }
        .onAppear {
            loadGroupDetails()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func loadGroupDetails() {
        let db = Firestore.firestore()
        db.collection("groups").document(groupId).getDocument { snapshot, error in
            isLoading = false
            if let error = error {
                alertMessage = "Failed to load group details: \(error.localizedDescription)"
                showAlert = true
                return
            }

            if let data = snapshot?.data() {
                let invitees = (data["invitees"] as? [[String: Any]])?.compactMap {
                    Member(email: $0["email"] as? String ?? "", hasAccepted: $0["hasAccepted"] as? Bool ?? false)
                } ?? []
                self.group = Group(id: groupId, name: data["name"] as? String ?? "", members: invitees)
            }
        }
    }

    func joinGroup() {
        let db = Firestore.firestore()
        guard let currentUser = Auth.auth().currentUser else { return }
        db.collection("groups").document(groupId).updateData([
            "invitees": FieldValue.arrayRemove([["email": currentUser.email ?? "", "hasAccepted": false]]),
            "members": FieldValue.arrayUnion([["email": currentUser.email ?? "", "hasAccepted": true]])
        ]) { error in
            if let error = error {
                alertMessage = "Failed to join group: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Successfully joined the group!"
                showAlert = true
            }
        }
    }
}

// Invite View for sending invitations
struct InviteView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var groupName = ""
    @State private var invitations: [String] = [""]
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var onSubmit: (String, [String]) -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Group Name Input
                TextField("Enter group name", text: $groupName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 20)
                    .font(.title2)
                    .frame(height: 55)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ColorPalette.sageGreen, lineWidth: 2)
                    )
                
                // Invitations List
                Text("Invite people (emails or phone numbers):")
                    .font(.headline)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(invitations.indices, id: \.self) { index in
                            HStack {
                                TextField("Enter email or phone", text: $invitations[index])
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.horizontal, 20)
                                    .font(.title2)
                                    .frame(height: 55)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(ColorPalette.sageGreen, lineWidth: 3)
                                    )
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                
                                // Remove Button
                                if invitations.count > 1 {
                                    Button(action: {
                                        invitations.remove(at: index)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        // Add Button
                        Button(action: {
                            invitations.append("")
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(ColorPalette.midnightBlue)
                                Text("Add another contact")
                                    .foregroundColor(ColorPalette.midnightBlue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
                
                Spacer()
                
                // Submit Button
                Button(action: {
                    if groupName.isEmpty {
                        alertMessage = "Please provide a group name."
                        showAlert = true
                        return
                    }
                    
                    let validContacts = invitations.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                    if validContacts.isEmpty {
                        alertMessage = "Please add at least one valid contact."
                        showAlert = true
                        return
                    }
                    
                    onSubmit(groupName, validContacts)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Create Group and Send Invites")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ColorPalette.midnightBlue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .navigationTitle("Create Group")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
