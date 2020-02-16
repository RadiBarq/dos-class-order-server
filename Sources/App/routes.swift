import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.post("books", "buy") { req -> Future<BuyResponse> in
        return try req.content.decode(BuyRequest.self).flatMap(to: BuyResponse.self) { buyRequest in
            
            let book = Book(id: buyRequest.bookId, title: "", category: "", price: 0, numberOfItems: 0)
            book.id = buyRequest.bookId
            
            let headers: HTTPHeaders = HTTPHeaders([("Content-Type", "application/json")])

            let checkAvailableRequest = HTTPRequest(
                method: .GET,
                url: URL(string: "/books/available/\(buyRequest.bookId)")!,
                headers: headers
            )
            
            let client = HTTPClient.connect(hostname: "40.68.168.196", port: 80, on: req)
            
            return client.flatMap(to: BuyResponse.self) { client in
                return client.send(checkAvailableRequest).flatMap(to: BuyResponse.self) { response in
                    let decoder = JSONDecoder()
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let bookAvailableResponse = try decoder.decode(BookAvailableResponse.self, from: response.body.data!)
                    
                    if bookAvailableResponse .available {
                        let book = bookAvailableResponse.book
                        guard let bookId = book.id else { return req.future(BuyResponse(success: false)) }
                        book.numberOfItems -= 1
                        let jsonData = try encoder.encode(book)
                        let jsonString = String(data: jsonData, encoding: .utf8)!
                        let updateBookRequest = HTTPRequest(
                            method: .PUT,
                            url: URL(string: "/books/number-of-items/\(bookId)")!,
                            headers: headers,
                            body: HTTPBody(string: jsonString)
                        )
                        return client.send(updateBookRequest).flatMap(to: BuyResponse.self) { response in
                            req.future(BuyResponse(success: true))
                        }
                    } else {
                        return req.future(BuyResponse(success: false))
                    }
                }
            }
        }
    }
}
