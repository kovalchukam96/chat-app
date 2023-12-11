import UIKit

struct ConversationContext {
    let avatar: AvatarImageView.ViewModel
    let channelID: String
    let name: String
}

final class ConversationFactory {
    
    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func build(with context: ConversationContext) -> ConversationViewController {
        let vc = ConversationViewController()
        
        let interactor = ConversationInteractor(
            chatService: container.chatService,
            coreDataService: container.coreDataService,
            conversationDataStore: container.conversationDataStore,
            channelID: context.channelID
        )
        
        let router = ConversationRouter()
        router.vc = vc

        let presenter = ConversationPresenter(
            view: vc,
            router: router,
            interactor: interactor,
            userStorage: container.userStorage,
            profileDataStore: container.profileDataStore,
            context: context
        )
        
        interactor.output = presenter

        vc.presenter = presenter

        return vc
    }
}
