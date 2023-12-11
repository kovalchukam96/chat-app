import UIKit

protocol ConversationsListRouterInput: AnyObject {
    func openConversation(avatar: AvatarImageView.ViewModel, channelID: String, name: String)
    func addChannel(with viewModel: AddChannelAlertControllerViewModel)
    func showAlert(with viewModel: ConversationsListErrorAlertControllerViewModel)
}

final class ConversationsListRouter {
    
    weak var vc: UIViewController?

    private let container: Container

    init(container: Container) {
        self.container = container
    }
}

// MARK: - ConversationsListRouterInput

extension ConversationsListRouter: ConversationsListRouterInput {

    func openConversation(avatar: AvatarImageView.ViewModel, channelID: String, name: String) {
        let conversationVC = ConversationFactory(container: container)
            .build(with: .init(avatar: avatar, channelID: channelID, name: name)
            )
        vc?.navigationController?.pushViewController(conversationVC, animated: true)
    }

    func addChannel(with viewModel: AddChannelAlertControllerViewModel) {
        let alertController = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: viewModel.textFieldAction)
        
        viewModel.actions.forEach {
            alertController.addAction($0)
        }
        vc?.present(alertController, animated: true)
    }
    
    func showAlert(with viewModel: ConversationsListErrorAlertControllerViewModel) {
        
        let alertController = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: viewModel.style)
        
        viewModel.actions.forEach {
            alertController.addAction($0)
        }
        vc?.present(alertController, animated: true)
    }
}
 struct ConversationsListErrorAlertControllerViewModel {
    let title: String
    let message: String?
    let style: UIAlertController.Style
    let actions: [UIAlertAction]
}

struct AddChannelAlertControllerViewModel {
    let title: String
    let textFieldAction: ((UITextField) -> Void)
    let actions: [UIAlertAction]
}
