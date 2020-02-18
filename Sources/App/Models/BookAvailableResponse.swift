//
//  BookAvailableRequest.swift
//  App
//
//  Created by Harri on 2/9/20.
//

import Vapor

/// Book Available Response.
final class BookAvailableResponse {
    
    /// To indicate if the book available or not.
    var available: Bool
    
    /// The book that is availabe or not.
    var book: Book
    
    /// Create a new `BookAvailableResponse`.
    init(available: Bool, book: Book) {
        self.available = available
        self.book = book
    }
}

/// Allows `BookAvailableResponse` to be encoded to and decoded from HTTP messages.
extension BookAvailableResponse: Content {}
