
import Foundation

protocol GetTweetsInteractor {
    func execute(completion: @escaping (_ tweets: [Twit]) -> ())
}

class GetTweetsInteractorDefault: GetTweetsInteractor {
    private var twitterRepository: TwitterRepository
    
    init() {
        twitterRepository = TwitterRepositoryDefault()
    }
    
    func execute(completion: @escaping (_ tweets: [Twit]) -> ()) {
        twitterRepository.getTwits(completion: completion)
    }
}
