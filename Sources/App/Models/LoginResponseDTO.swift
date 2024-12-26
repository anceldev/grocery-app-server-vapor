//
//  File.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 26/12/24.
//

import Foundation
import Vapor

struct LoginResponseDTO: Content {
    let error: Bool
    var reason: String? = nil
    let token: String?
    let userId: UUID
}
