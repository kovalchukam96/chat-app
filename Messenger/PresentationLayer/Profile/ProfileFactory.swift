import UIKit

final class ProfileFactory {

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func build() -> ProfileViewController {
        let vc = ProfileViewController()
        let router = ProfileRouter(container: container)
        let interactor = ProfileInteractor(dataStore: container.profileDataStore)
        router.vc = vc
        
        let presenter = ProfilePresenter(
            view: vc,
            router: router,
            interactor: interactor
        )

        vc.presenter = presenter

        return vc
    }
}
