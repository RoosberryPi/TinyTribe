//
//  Request.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 15/11/2024.
//

import SwiftUI

struct Request: Identifiable {
    var id: String
    let date: Date
    let isUrgent: Bool
    let isMyRequest: Bool
    let requesterName: String
}
