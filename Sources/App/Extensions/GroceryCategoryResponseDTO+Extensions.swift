//
//  File.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 27/12/24.
//

import Foundation
import GroceryAppShareDTO
import Vapor

extension GroceryCategoryResponseDTO: Content {
    
    init?(_ groceryCategory: GroceryCategory) {
        guard let id = groceryCategory.id else { return nil }
        self.init(id: id, title: groceryCategory.title, colorCode: groceryCategory.colorCode, items: groceryCategory.items.compactMap(GroceryItemResponseDTO.init))
    }
}
