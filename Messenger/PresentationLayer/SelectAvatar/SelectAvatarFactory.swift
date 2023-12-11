import UIKit

final class SelectAvatarFactory {
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func build(completion: @escaping (UIImage) -> Void) -> SelectAvatarViewController {
        let vc = SelectAvatarViewController(collectionManager: .init(imageLoader: container.imageLoader))
        
        let router = SelectAvatarRouter(completion: completion)
        
        router.vc = vc
        
        let selectAvatarService = SelectAvatarServiceImpl(client: container.networkClient)
        
        let interactor = SelectAvatarInteractor(selectAvatarService: selectAvatarService)

        let presenter = SelectAvatarPresenter(
            view: vc,
            interactor: interactor,
            router: router
        )

        vc.presenter = presenter

        return vc
    }
}
