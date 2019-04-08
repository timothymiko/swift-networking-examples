import Foundation
import PlaygroundSupport

enum APIError: Error {
    case invalidURL
    case requestFailed
}

struct APIClient {

    typealias APIClientCompletion = (HTTPURLResponse?, Data?, APIError?) -> Void

    private let session = URLSession.shared
    private let baseURL = URL(string: "https://jsonplaceholder.typicode.com")

    func request(method: String, path: String, _ completion: @escaping APIClientCompletion) {
        guard let url = baseURL?.appendingPathComponent(path) else {
            completion(nil, nil, .invalidURL); return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, nil, .requestFailed); return
            }
            completion(httpResponse, data, nil)
        }
        task.resume()
    }
}

APIClient().request(method: "get", path: "todos/1") { (_, data, _) in
    if let data = data, let result = String(data: data, encoding: .utf8) {
        print(result)
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
