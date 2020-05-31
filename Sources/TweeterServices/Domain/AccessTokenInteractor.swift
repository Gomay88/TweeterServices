
protocol AccessTokenInteractor {
    func execute(completion: @escaping (Bool) -> ())
}

class AccessTokenInteractorDefault: AccessTokenInteractor {
    private var twitterRepository: TwitterRepository
    
    init() {
        twitterRepository = TwitterRepositoryDefault()
    }
    
    func execute(completion: @escaping (Bool) -> ()) {
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
