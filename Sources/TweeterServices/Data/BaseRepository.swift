
import Foundation

protocol BaseRepository {
    func execute<T: Decodable>(request: HttpRequest, responseType: T.Type, completion: @escaping ((_ data: T?, _ error: Error?)->()))
}

extension BaseRepository {
    func execute<T: Decodable>(request: HttpRequest, responseType: T.Type, completion: @escaping ((_ data: T?, _ error: Error?)->())) {
        var urlComponents = URLComponents(string: request.stringURL)
        
        if let data = request.parameter?.toJson(), request.encoded == .url {
            var queryItems = [URLQueryItem]()
            for (key,param) in data {
                queryItems.append(URLQueryItem(name: key, value: param as? String))
            }
            
            urlComponents?.queryItems = queryItems
        }
        
        guard let url = urlComponents?.url else {
            completion(nil, RepositoryError.urlError)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        if request.encoded == .body {
            urlRequest.httpBody = request.parameter?.data()
            urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        }
        
        for header in request.headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    completion(nil, RepositoryError.serverError)
                    return
            }
            
            #if DEBUG
            if let url = response.url {
                print("⬅️ URL: \(url)")
            }
            
            print("⬅️ Statuscode: \(response.statusCode)")
            
            if let data = data,
                let body = String(bytes: data, encoding: .utf8) {
                print("⬅️ Body: \(body)")
            }
            
            if let error = error {
                print("⬅️ Error: \(error)")
            }
            #endif
            
            guard let data = data else {
                completion(nil, RepositoryError.nilDataError)
                return
            }
            
            self.decodeData(data: data, type: responseType, completion: completion)
        }
        
        task.resume()
    }
    
    func decodeData<T: Decodable>(data: Data, type: T.Type, completion: @escaping((_ decodeObject: T?, _ error: Error?) -> ())) {
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            let jsonData = try JSONSerialization.data(withJSONObject: json)
        
            completion(try JSONDecoder().decode(type, from: jsonData), nil)
        } catch {
            guard let dataString = String(data: data, encoding: .utf8) else {
                let error = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: error.localizedDescription))
                completion(nil, error)
                return
            }
            
            completion(dataString as? T, nil)
        }
    }
}

enum RepositoryError: Error {
    case mapError
    case nilDataError
    case serverError
    case urlError
    case encodedHeaderError
}

extension Encodable {
    func toJson() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return nil }
        return result
    }
    
    func data() -> Data? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        
        return data
    }
}
