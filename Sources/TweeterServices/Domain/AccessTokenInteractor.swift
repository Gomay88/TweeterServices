
public protocol AccessTokenInteractor {
    func execute(completion: @escaping (Bool) -> ())
}

public class AccessTokenInteractorDefault: AccessTokenInteractor {
    private var twitterRepository: TwitterRepository
    
    init() {
        twitterRepository = TwitterRepositoryDefault()
    }
    
    public func execute(completion: @escaping (Bool) -> ()) {
        twitterRepository.oauthAccessToken { (token, error) in
            guard let token = token else {
                completion(false)
                return
            }
            
            Constants.oauthToken = token
            completion(true)
        }
    }
}
