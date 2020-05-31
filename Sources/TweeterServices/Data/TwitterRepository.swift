
import Foundation
import CommonCrypto

protocol TwitterRepository {
    func requestToken(completion: @escaping (RequestOAuthTokenResponse?, Error?) -> ())
    func oauthAuthorize(token: String, completion: @escaping (String?, Error?) -> ())
    func oauthAccessToken(completion: @escaping (String?, Error?) -> ())
    func getTwits(completion: @escaping ([Twit]) -> ())
}

class TwitterRepositoryDefault: BaseRepository, TwitterRepository {
    func requestToken(completion: @escaping (RequestOAuthTokenResponse?, Error?) -> ()) {
        Constants.uuid = UUID().uuidString
        
        var headers: [String: String] = [:]
        headers.updateValue("MyTweeter://", forKey: "oauth_callback")
        headers.updateValue(Constants.apiKey, forKey: "oauth_consumer_key")
        headers.updateValue(Constants.uuid, forKey: "oauth_nonce")
        headers.updateValue("HMAC-SHA1", forKey: "oauth_signature_method")
        headers.updateValue(String(Int(Date().timeIntervalSince1970)), forKey: "oauth_timestamp")
        headers.updateValue("1.0", forKey: "oauth_version")
        
        let oauthSignatureHeader = oauthSignature(method: "POST", url: "https://api.twitter.com/oauth/request_token", headers: headers)
        headers.updateValue(oauthSignatureHeader, forKey: "oauth_signature")
        
        var headerString = [String]()
        for header in headers {
            let key = header.key.urlEncoded
            let value = header.value.urlEncoded
            headerString.append("\(key)=\"\(value)\"")
        }
        
        let finalHeader = ["Authorization": "OAuth \(headerString.sorted().joined(separator: ", "))"]
        
        let request = RequestBuilder.twitter()
            .post()
            .headers(finalHeader)
            .encoded(.url)
            .path("oauth/request_token")
            .builtHttpRequest()
        
        execute(request: request, responseType: String.self) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            let attributes = data.urlQueryStringParameters
            
            let result = RequestOAuthTokenResponse(oauthToken: attributes["oauth_token"] ?? "",
                                                   oauthTokenSecret: attributes["oauth_token_secret"] ?? "",
                                                   oauthCallbackConfirmed: attributes["oauth_callback_confirmed"] ?? "")
            
            Constants.oauthToken = result.oauthToken
            completion(result, nil)
        }
    }
    
    func oauthAuthorize(token: String, completion: @escaping (String?, Error?) -> ()) {
        let request = RequestBuilder.twitter()
            .get()
            .parameter(["oauth_token": token])
            .path("oauth/authorize")
            .builtHttpRequest()
        
        execute(request: request, responseType: String.self, completion: completion)
    }
    
    func oauthAccessToken(completion: @escaping (String?, Error?) -> ()) {
        let request = RequestBuilder.twitter()
            .post()
            .parameter(["oauth_token": Constants.oauthToken, "oauth_verifier": Constants.oauthVerifier])
            .encoded(.url)
            .path("oauth/access_token")
            .builtHttpRequest()
        
        execute(request: request, responseType: String.self) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            let attributes = data.urlQueryStringParameters
            completion(attributes["oauth_token"], nil)
        }
    }
    
    func getTwits(completion: @escaping ([Twit]) -> ()) {
        var headers: [String: String] = [:]
        headers.updateValue(Constants.apiKey, forKey: "oauth_consumer_key")
        headers.updateValue(Constants.uuid, forKey: "oauth_nonce")
        headers.updateValue("HMAC-SHA1", forKey: "oauth_signature_method")
        headers.updateValue(String(Int(Date().timeIntervalSince1970)), forKey: "oauth_timestamp")
        headers.updateValue(Constants.oauthToken, forKey: "oauth_token")
        headers.updateValue("1.0", forKey: "oauth_version")
        
        let oauthSignatureHeader = oauthSignature(method: "POST", url: "https://stream.twitter.com/1.1/statuses/filter.json", headers: headers)
        headers.updateValue(oauthSignatureHeader, forKey: "oauth_signature")
        
        var headerString = [String]()
        for header in headers {
            let key = header.key.urlEncoded
            let value = header.value.urlEncoded
            headerString.append("\(key)=\"\(value)\"")
        }
        
        let finalHeader = ["Authorization": "OAuth \(headerString.sorted().joined(separator: ", "))"]
        
        _ = RequestBuilder.stream()
            .post()
            .headers(finalHeader)
            .path("statuses/filter.json?track=I,me")
            .encoded(.url)
            .builtHttpRequest()
        
        //Here will go my request and everytime I get the correct response I save twits in userdefaults and then with every error I can show the last ones I got stored but because I haven't been able to make the request I mock it.
        completion(twitsData)
    }
    
    private func oauthSignature(method: String, url: String, headers: [String: Any]) -> String {
        let signingKey = Constants.apiSecret.urlEncoded+"&"
        let signatureBase = signatureBaseString(method: method, url: url, headers: headers)
        return hmac_sha1(signingKey: signingKey, signatureBase: signatureBase)
    }
    
    private func signatureBaseString(method: String, url: String, headers: [String:Any]) -> String {
        return method + "&" + url.urlEncoded + "&" + signatureParameterString(headers: headers)
    }
    
    private func signatureParameterString(headers: [String: Any]) -> String {
        var result: [String] = []
        for header in headers {
            let key = header.key.urlEncoded
            let val = "\(header.value)".urlEncoded
            result.append("\(key)=\(val)")
        }
        return result.sorted().joined(separator: "&").urlEncoded
    }
    
    private func hmac_sha1(signingKey: String, signatureBase: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), signingKey, signingKey.count, signatureBase, signatureBase.count, &digest)
        let data = Data(digest)
        return data.base64EncodedString()
    }
}
