//
//  CreateUsersTableMigration.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 26/12/24.
//

import Foundation
import Fluent

struct CreateUsersTableMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required).unique(on: "username")
            .field("password", .string, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .delete()
    }
}
