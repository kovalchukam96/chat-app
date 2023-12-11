import Foundation

enum ErrorResponse: String {
    case invalidEndpoint
    case invalidResponse
    case inalidComponents
}

protocol NetworkClient {
    func request<Request: DataRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    )
}

final class NetworkClientImpl: NetworkClient {
    
    func request<Request: DataRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    ) {
    
        guard var urlComponent = URLComponents(string: request.url) else {
            let error = NSError(
                domain: ErrorResponse.invalidEndpoint.rawValue,
                code: 404,
                userInfo: nil
            )
            
            return completion(.failure(error))
        }
        
        var queryItems: [URLQueryItem] = []
        
        request.queryItems.forEach {
            let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value)
            urlComponent.queryItems?.append(urlQueryItem)
            queryItems.append(urlQueryItem)
        }
        
        urlComponent.queryItems = queryItems
        
        guard let url = urlComponent.url else {
            let error = NSError(
                domain: ErrorResponse.invalidEndpoint.rawValue,
                code: 404,
                userInfo: nil
            )
            
            return completion(.failure(error))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                return completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            }
            
            guard let data = data else {
                return completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            }
            
            do {
                try completion(.success(request.decode(data)))
            } catch let error as NSError {
                completion(.failure(error))
            }
        }
        .resume()
    }
}
