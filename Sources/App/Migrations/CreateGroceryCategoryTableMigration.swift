//
//  File.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 27/12/24.
//

import Foundation
import Fluent

class CreateGroceryCategoryTableMigration: AsyncMigration, @unchecked Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema("grocery_categories")
            .id()
            .field("title", .string, .required)
            .field("color_code", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("grocery_categories").delete()
    }
}
