//
//  BuyRequest.swift
//  App
//
//  Created by Harri on 2/10/20.
//

import Vapor

/// Buy Book Request.
final class BuyBookRequest {
    
    /// Book id.
    let bookId: Int

    /// Create `BuyRequest`.
    init(bookId: Int) {
        self.bookId = bookId
    }
}

/// Allows `BuyBookRequest` to be encoded to and decoded from HTTP messages.
extension BuyBookRequest: Content {}
