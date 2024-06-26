//
//  Order.swift
//  Shopify
//
//  Created by Rawan Elsayed on 12/06/2024.
//

import Foundation

struct ConfirmOrder: Codable {
    //let email: String?
    let line_items: [LineItem]?
    let financial_status: String?
    //let shipping_address: Address?
    let currency: String?
    let phone: String?
    let customer: CustomerOrder?
//    let subtotal_price: String?
    let total_discounts: String?
    //let total_price: String?
    let current_total_price: String?
    let total_tax: String?
    let created_at: String?
    let shipping_address: DefaultAddress?
    let send_receipt: Bool?
    let inventory_behaviour : String?
}

struct OrdersResponse: Codable {
    let orders: [ConfirmOrder]
}

struct CustomerOrder: Codable {
    let id: Int
//    let email: String?
//    let first_name: String?
//    let last_name: String?
//    let phone: String?
}





struct GetOrder: Codable {
    //let email: String?
    let line_items: [LineItem]?
    let financial_status: String?
    //let shipping_address: Address?
    let currency: String?
    let phone: String?
    let customer: CustomerOrders?
    let subtotal_price: String?
    let total_discounts: String?
    let total_price: String?
    let created_at: String?
    let shipping_address: DefaultAddress?
}

struct CustomerOrders: Codable {
    let id: Int
    let email: String?
    let first_name: String?
    let last_name: String?
    let default_address: DefaultAddress?
}

struct DefaultAddress: Codable{
    let address1: String?
}



