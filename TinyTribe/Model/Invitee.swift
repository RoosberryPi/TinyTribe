//
//  File.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 21/11/2024.
//

import SwiftUI

struct Member: Identifiable, Codable {
    var id = UUID()
    let email: String
    var hasAccepted: Bool
}
