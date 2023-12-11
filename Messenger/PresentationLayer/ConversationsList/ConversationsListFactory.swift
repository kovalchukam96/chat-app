import UIKit

final class ConversationsListFactory {
    
    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func build() -> ConversationsListViewController {
        let vc = ConversationsListViewController()
        
        _ = container.logger
        
        let interactor = ConversationsListInteractor(
            profileDataStore: container.profileDataStore,
            chatService: container.chatService,
            coreDataService: container.coreDataService,
            conversationsListDataStore: container.conversationsListDataStore
        )

        let router = ConversationsListRouter(container: container)
        router.vc = vc

        let presenter = ConversationsListPresenter(
            view: vc,
            router: router,
            interactor: interactor
        )
        
        interactor.output = presenter
        
        vc.presenter = presenter

        return vc
    }
}
