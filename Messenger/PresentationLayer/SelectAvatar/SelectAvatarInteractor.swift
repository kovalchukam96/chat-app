import UIKit

protocol SelectAvatarInteractorInput {
    func getImages(completion: @escaping (Result<SelectAvatarModel, Error>) -> Void)
    func getInitialImages(completion: @escaping (Result<SelectAvatarModel, Error>) -> Void)
}

enum SelectAvatarError: Error {
    case getImagesError
}

final class SelectAvatarInteractor {
    
    var isBusy = false
    private let selectAvatarService: SelectAvatarService
    
    private var currentPage = 1
    
    private var images: SelectAvatarModel?
    
    init(selectAvatarService: SelectAvatarService) {
        self.selectAvatarService = selectAvatarService
    }
}

extension SelectAvatarInteractor: SelectAvatarInteractorInput {
    
    func getInitialImages(completion: @escaping (Result<SelectAvatarModel, Error>) -> Void) {
        currentPage = 1
        getImages(completion: completion)
    }
    
    func getImages(completion: @escaping (Result<SelectAvatarModel, Error>) -> Void) {
        if isBusy {
            return
        }
        if let images = images, images.hits.count == images.total {
            DispatchQueue.main.async {
                completion(.success(images))
            }
            return
        }
        isBusy = true
        selectAvatarService.getImages(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.isBusy = false
                self.currentPage += 1
                if self.images == nil {
                    self.images = response
                } else {
                    self.images?.hits.append(contentsOf: response.hits)
                }
                guard let images = self.images else {
                    DispatchQueue.main.async {
                        completion(.failure(SelectAvatarError.getImagesError))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(images))
                }
            case .failure:
                DispatchQueue.main.async {
                    completion(.failure(SelectAvatarError.getImagesError))
                }
            }
        }
    }
}
