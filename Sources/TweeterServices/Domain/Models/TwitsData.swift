
import Foundation

public let twitsData: [Twit] = load("TwitsData.json")

private func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    for bundle in Bundle.allBundles {
        if let file = bundle.url(forResource: filename, withExtension: nil) {
            do {
                data = try Data(contentsOf: file)
            } catch {
                fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
            }
        } else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
    }
    
    fatalError("Couldn't find \(filename) in main bundle.")
}
