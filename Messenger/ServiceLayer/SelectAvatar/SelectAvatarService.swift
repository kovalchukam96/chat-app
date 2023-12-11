import Foundation

protocol SelectAvatarService {
    func getImages(page: Int, completion: @escaping (Result<SelectAvatarModel, Error>) -> Void)
}

class SelectAvatarServiceImpl: SelectAvatarService {
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func getImages(page: Int, completion: @escaping (Result<SelectAvatarModel, Error>) -> Void) {
        guard let request = SelectAvatarRequest(page: page, pageSize: 20) else { return }
        client.request(request) { result in
            switch result {
            case .success(let dto):
                completion(.success(.init(from: dto)))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}
