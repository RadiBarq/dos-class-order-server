import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    /// Registers routes to the incoming buy books requests
    ///
    /// - parameters:
    ///     - path: Variadic `PathComponentsRepresentable` items.
    ///     - closure: Creates a `Response` for the incoming `Request`.
    /// - returns: The buy response
    router.post("books", "buy") { req -> Future<BuyBookResponse> in
        return try req.content.decode(BuyBookRequest.self).flatMap(to: BuyBookResponse.self) { buyRequest in
            let book = Book(id: buyRequest.bookId, title: "", category: "", price: 0, numberOfItems: 0)
            book.id = buyRequest.bookId
            let headers: HTTPHeaders = HTTPHeaders([("Content-Type", "application/json")])
            let checkAvailableRequest = HTTPRequest(
                method: .GET,
                url: URL(string: "/books/available/\(buyRequest.bookId)")!,
                headers: headers
            )
            let client = HTTPClient.connect(hostname: "localhost", port: 8100, on: req)
            return client.flatMap(to: BuyBookResponse.self) { client in
                return client.send(checkAvailableRequest).flatMap(to: BuyBookResponse.self) { response in
                    let decoder = JSONDecoder()
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let bookAvailableResponse = try decoder.decode(BookAvailableResponse.self, from: response.body.data!)
                    if bookAvailableResponse .available {
                        let book = bookAvailableResponse.book
                        guard let bookId = book.id else { return req.future(BuyBookResponse(success: false)) }
                        book.numberOfItems -= 1
                        let jsonData = try encoder.encode(book)
                        let jsonString = String(data: jsonData, encoding: .utf8)!
                        let updateBookRequest = HTTPRequest(
                            method: .PUT,
                            url: URL(string: "/books/number-of-items/\(bookId)")!,
                            headers: headers,
                            body: HTTPBody(string: jsonString)
                        )
                        return client.send(updateBookRequest).flatMap(to: BuyBookResponse.self) { response in
                            req.future(BuyBookResponse(success: true))
                        }
                    } else {
                        return req.future(BuyBookResponse(success: false))
                    }
                }
            }
        }
    }
}
