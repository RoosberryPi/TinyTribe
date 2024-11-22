//
//  Group.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 21/11/2024.
//

import SwiftUI

struct Group: Identifiable, Decodable {
    let id: String
    var name: String
    let members: [Member]
}
