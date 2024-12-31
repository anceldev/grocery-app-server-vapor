//
//  File.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 30/12/24.
//

import Foundation
import Vapor
import GroceryAppShareDTO

extension GroceryItemResponseDTO: Content {
    init?(_ groceryItem: GroceryItem) {
        guard let groceryItemId = groceryItem.id else {
            return nil
        }
        self.init(id: groceryItemId, title: groceryItem.title, price: groceryItem.price, quantity: groceryItem.quantity)
    }
}
