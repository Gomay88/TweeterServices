
import Foundation

public protocol GetTweetsInteractor {
    func execute(completion: @escaping (_ tweets: [Twit]) -> ())
}

public class GetTweetsInteractorDefault: GetTweetsInteractor {
    private var twitterRepository: TwitterRepository
    
    public init() {
        twitterRepository = TwitterRepositoryDefault()
    }
    
    public func execute(completion: @escaping (_ tweets: [Twit]) -> ()) {
        twitterRepository.getTwits(completion: completion)
    }
}
