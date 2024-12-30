//
//  File.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 27/12/24.
//

import Foundation
import Vapor
import Fluent
import GroceryAppShareDTO

final class GroceryController: RouteCollection, @unchecked Sendable {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "users", ":userId")
        
        // POST: Saving GroceryCategory
        // /api/users/:userId/grocer-categories
//        api.post("crogery-categories", use: saveGroceryCategory)
        api.post("grocery-categories") { [self] req async throws -> GroceryCategoryResponseDTO in
            try await saveGroceryCategory(req: req)
        }
        api.get("grocery-categories") { [self] req async throws -> [GroceryCategoryResponseDTO] in
            try await getGroceryCategoryByUser(req: req)
        }
        
        api.delete("grocery-categories", ":groceryCategoryId") { [self] req async throws -> GroceryCategoryResponseDTO in
            try await deleteGroceryCategory(req: req)
        }
    }
    
    func deleteGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let groceryCategory = try await  GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
                throw Abort(.notFound)
            }
        
        try await groceryCategory.delete(on: req.db)
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        return groceryCategoryResponseDTO
    }
    
    func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        
        // DTO for the request
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)
        let groceryCategory = GroceryCategory(
            title: groceryCategoryRequestDTO.title,
            colorCode: groceryCategoryRequestDTO.colorCode,
            userId: userId
        )
        try await groceryCategory.save(on: req.db)
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        
        return groceryCategoryResponseDTO
    }
    func getGroceryCategoryByUser(req: Request) async throws -> [GroceryCategoryResponseDTO] {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .all()
            .compactMap(GroceryCategoryResponseDTO.init)
    }
}
