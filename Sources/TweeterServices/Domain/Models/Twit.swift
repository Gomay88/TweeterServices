
import Foundation

public struct Twit: Codable {
    public let id: Int
    public let twitText: String
    public let avatar: String
    public let name: String
    public let longitude: Double?
    public let latitude: Double?
    public let followers: Int
    public let tweets: Int
    public let favourites: Int
    public let retweet: Int
    public let reply: Int
    
    public var avatarURLPath: URL? {
        guard let url = URL(string: avatar) else {
            return nil
        }
        
        return url
    }
}
