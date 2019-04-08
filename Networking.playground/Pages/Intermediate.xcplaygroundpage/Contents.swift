import Foundation
import PlaygroundSupport

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
}

struct HTTPHeader {
    let field: String
    let value: String
}

class APIRequest {
    let method: HTTPMethod
    let path: String
    var queryItems: [URLQueryItem]?
    var headers: [HTTPHeader]?
    var body: Data?

    init(method: HTTPMethod, path: String) {
        self.method = method
        self.path = path
    }
}

enum APIError: Error {
    case invalidURL
    case requestFailed
}

struct APIClient {

    typealias APIClientCompletion = (HTTPURLResponse?, Data?, APIError?) -> Void

    private let session = URLSession.shared
    private let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!

    func request(_ request: APIRequest, _ completion: @escaping APIClientCompletion) {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path
        urlComponents.queryItems = request.queryItems

        guard let url = urlComponents.url?.appendingPathComponent(request.path) else {
            completion(nil, nil, .invalidURL); return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, nil, .requestFailed); return
            }
            completion(httpResponse, data, nil)
        }
        task.resume()
    }
}

let request = APIRequest(method: .post, path: "posts")
request.queryItems = [URLQueryItem(name: "hello", value: "world")]
request.headers = [HTTPHeader(field: "Content-Type", value: "application/json")]
request.body = Data() // example post body

APIClient().request(request) { (_, data, _) in
    if let data = data, let result = String(data: data, encoding: .utf8) {
        print(result)
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

