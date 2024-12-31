//
//  File.swift
//  grocery-app-server
//
//  Created by Ancel Dev account on 30/12/24.
//

import Foundation
import Fluent
import Vapor

final class GroceryItem: Model, Content {
    static let schema = "grocery_items"
    
    @ID(key: .id)
    var id: (UUID?)
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "quantity")
    var quantity: Int
    
    @Parent(key: "grocery_category_id")
    var groceryCategory: GroceryCategory
    
    init(){ }
    
    init(id: UUID? = nil, title: String, price: Double, quantity: Int, groceryCategoryId: UUID) {
        self.id = id
        self.title = title
        self.price = price
        self.quantity = quantity
        self.$groceryCategory.id = groceryCategoryId
    }
}
