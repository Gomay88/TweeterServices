
import Foundation

struct Twit: Codable {
    let id: Int
    let twitText: String
    let avatar: String
    let name: String
    let longitude: Double?
    let latitude: Double?
    let followers: Int
    let tweets: Int
    let favourites: Int
    let retweet: Int
    let reply: Int
    
    var avatarURLPath: URL? {
        guard let url = URL(string: avatar) else {
            return nil
        }
        
        return url
    }
}
