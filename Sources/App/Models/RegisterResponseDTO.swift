//
//  File.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 26/12/24.
//

import Foundation
import Vapor

struct RegisterResponseDTO: Content {
    let error: Bool
    var reason: String? = nil
}
