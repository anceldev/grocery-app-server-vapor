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
        let api = routes.grouped("api", "users", ":userId").grouped(JSONWebTokenAuthenticator())
        
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
        
        api.post("grocery-categories", ":groceryCategoryId", "grocery-items") { [self] req async throws -> GroceryItemResponseDTO in
            try await saveGroceryItem(req: req)
        }
        api.get("grocery-categories", ":groceryCategoryId", "grocery-items") { [self] req async throws -> [GroceryItemResponseDTO] in
            try await getGroceryItemsByGroceryCategory(req: req)
        }
        api.delete("grocery-categories", ":groceryCategoryId", "grocery-items", ":groceryItemId") { [self] req async throws -> GroceryItemResponseDTO in
            try await deleteGroceryItem(req: req)
        }
        
        // OPTIONAL: Get all grocery cateogries with their items
        api.get("grocery-categories-with-items") { [self] req async throws -> [GroceryCategoryResponseDTO] in
            try await getGroceryCategoriesWithItems(req: req)
        }
    }
    
    func getGroceryCategoriesWithItems(req: Request) async throws -> [GroceryCategoryResponseDTO] {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .with(\.$items)
            .all()
            .compactMap(GroceryCategoryResponseDTO.init)
    }
    
    func deleteGroceryItem(req: Request) async throws -> GroceryItemResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self),
              let groceryItemId = req.parameters.get("groceryItemId", as: UUID.self) else {
            throw Abort(.notFound)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        guard let groceryItem = try await GroceryItem.query(on: req.db)
            .filter(\.$id == groceryItemId)
            .filter(\.$groceryCategory.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        try await groceryItem.delete(on: req.db)
        
        guard let groceryItemResponseDTO = GroceryItemResponseDTO(groceryItem) else {
            throw Abort(.internalServerError)
        }
        return groceryItemResponseDTO
    }
    
    func getGroceryItemsByGroceryCategory(req: Request) async throws -> [GroceryItemResponseDTO] {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        let groceryItemsResponseDTO = try await GroceryItem.query(on: req.db)
            .filter(\.$groceryCategory.$id == groceryCategory.id!)
            .all()
            .compactMap(GroceryItemResponseDTO.init)
        return groceryItemsResponseDTO
    }
    
    func saveGroceryItem(req: Request) async throws -> GroceryItemResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        let groceryRequestDTO = try req.content.decode(GroceryItemRequestDTO.self)
        let groceryItem = GroceryItem(
            title: groceryRequestDTO.title,
            price: groceryRequestDTO.price,
            quantity: groceryRequestDTO.quantity,
            groceryCategoryId: groceryCategory.id!
        )
        
        try await groceryItem.save(on: req.db)
        guard let gorceryItemResponseDTO = GroceryItemResponseDTO(groceryItem) else {
            throw Abort(.internalServerError)
        }
        
        return gorceryItemResponseDTO
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
