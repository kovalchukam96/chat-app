import UIKit

protocol SelectAvatarViewOutput: AnyObject {
    func downloadImage(for indexPath: IndexPath) -> UIImage
    func viewLoaded()
    func didSelectAvatar(with image: UIImage)
    func didScrollToBottom()
}

final class SelectAvatarPresenter {
    
    private weak var view: SelectAvatarViewInput?
    private let interactor: SelectAvatarInteractorInput
    
    private let router: SelectAvatarRouterInput
    
    init(view: SelectAvatarViewInput, interactor: SelectAvatarInteractorInput, router: SelectAvatarRouterInput) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func getInitialImages() {
        interactor.getInitialImages { [weak self] result in
            guard let self = self else { return }
            self.presentImages(result: result)
        }
    }
    
    private func getImages() {
        interactor.getImages { [weak self] result in
            guard let self = self else { return }
            self.presentImages(result: result)
        }
    }
    
    private func presentImages(result: Result<SelectAvatarModel, Error>) {
        switch result {
            
        case .success(let response):
            var urls: [URL] = []
            for hit in response.hits {
                if let url = URL(string: hit.previewURL) {
                    urls.append(url)
                }
            }
            view?.displayData(with: urls)
        case .failure:
            self.presentErrorAllert(with: SelectAvatarError.getImagesError)
        }
    }
    
    private func presentErrorAllert(with error: SelectAvatarError) {
        switch error {
        case .getImagesError:
            let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.getInitialImages()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            router.showAlert(with: .init(title: "Could not load images", message: "Try again", style: .alert, actions: [tryAgainAction, cancelAction]))
        }
        
    }
}

extension SelectAvatarPresenter: SelectAvatarViewOutput {
    func downloadImage(for indexPath: IndexPath) -> UIImage {
       let image = UIImage()
        return image
    }
    
    func viewLoaded() {
        getInitialImages()
    }
    
    func didSelectAvatar(with image: UIImage) {
        router.close(with: image)
    }
    
    func didScrollToBottom() {
        getImages()
    }
    
}
