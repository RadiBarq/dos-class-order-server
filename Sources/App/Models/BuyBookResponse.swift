import Vapor

/// Buy Book Response.
final class BuyBookResponse {
    
    /// To indicate if buy operation succeeded or not.
    var success: Bool

    /// Create a new `Buy Response`.
    init(success: Bool) {
        self.success = success
    }
}

/// Allows `BuyBookResponse` to be encoded to and decoded from HTTP messages.
extension BuyBookResponse: Content { }
