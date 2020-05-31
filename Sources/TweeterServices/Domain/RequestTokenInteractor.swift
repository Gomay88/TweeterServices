
import Foundation

public protocol RequestTokenInteractor {
    func execute(completion: @escaping (_ url: String?, _ error: Error?) -> ())
}

public class RequestTokenInteractorDefault: RequestTokenInteractor {
    private var twitterRepository: TwitterRepository
    
    public init() {
        twitterRepository = TwitterRepositoryDefault()
    }
    
    public func execute(completion: @escaping (_ url: String?, _ error: Error?) -> ()) {
        twitterRepository.requestToken { (requestOAuthTokenResponse, error) in
            guard let token = requestOAuthTokenResponse?.oauthToken else {
                completion(nil, error)
                return
            }
            
            completion("https://api.twitter.com/oauth/authorize?oauth_token=\(token)", nil)
        }
    }
}
