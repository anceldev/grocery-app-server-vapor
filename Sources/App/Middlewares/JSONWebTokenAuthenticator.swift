//
//  File.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 31/12/24.
//

import Foundation
import Vapor

struct JSONWebTokenAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Request) async throws {
        try request.jwt.verify(as: AuthPayload.self)
    }
}
