//
//  UserController.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 26/12/24.
//

import Foundation
import Vapor
import Fluent
import GroceryAppShareDTO

// /api/register
// /api/login

class UserController: RouteCollection, @unchecked Sendable {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let api = routes.grouped("api")
        
//        api.post("register", use: register)
//        api.post("login", use: login)
        
        api.post("register") { [self] req async throws -> RegisterResponseDTO in
            try await register(req: req)
        }
        
        api.post("login") { [self] req async throws -> LoginResponseDTO in
            try await login(req: req)
        }
    }
    
    func login(req: Request) async throws -> LoginResponseDTO {
        // decode the request
        let user = try req.content.decode(User.self)
         // check if the user exists in the db
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() else {
                throw Abort(.badRequest)
            }
        
        // validate the password
        let result = try await req.password.async.verify(user.password, created: existingUser.password)
        if  !result {
            throw Abort(.unauthorized)
        }
        let authPayload = try AuthPayload(
            expiration: .init(value: .distantFuture),
            userId: existingUser.requireID()
        )
        let response = try LoginResponseDTO(
            error: false,
            token: req.jwt.sign(authPayload),
            userId: existingUser.requireID()
        )
        
        return response
    }
    
    func register(req: Request) async throws -> RegisterResponseDTO {
        //  validate the user // validations
        try User.validate(content: req)
        let user = try req.content.decode(User.self)
       // fiond if the user already exists using th username
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            throw Abort(.conflict, reason: "Username is already taken.")
        }
        // hash the password

        user.password = try await req.password.async.hash(user.password)
        try await user.save(on: req.db)
        
        return RegisterResponseDTO(error: false)
    }
}
