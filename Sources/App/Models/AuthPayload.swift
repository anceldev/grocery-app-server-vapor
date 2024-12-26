//
//  File.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 26/12/24.
//

import Foundation
//import JWT
import Vapor
import JWT

struct AuthPayload: JWTPayload {
    typealias Payload = AuthPayload
    
//    enum CodingKeys: String, CodingKey {
//        case subjetct = "sub"
//        case expiration = "exp"
//        case userId = "uid"
//    }

    var expiration: ExpirationClaim
    var userId: UUID

    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}
