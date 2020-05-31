
import Foundation

open class HttpRequest {
    open var stringURL: String
    open var method: HTTPMethod
    open var parameter: Encodable?
    open var headers: [String:String]
    open var encoded: Encoded
    
    public init(stringURL: String, method: HTTPMethod, headers: [String:String], parameter: Encodable?, encoded: Encoded) {
        self.stringURL = stringURL
        self.method = method
        self.headers = headers
        self.parameter = parameter
        self.encoded = encoded
    }
}
