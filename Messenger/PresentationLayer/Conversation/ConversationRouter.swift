import UIKit

protocol ConversationRouterInput: AnyObject {
    func returnBack()
    func showAlert(with viewModel: ConversationErrorAlertControllerViewModel)
}

final class ConversationRouter {
    
    weak var vc: UIViewController?
}

// MARK: - ConversationRouterInput

extension ConversationRouter: ConversationRouterInput {
    func returnBack() {
        vc?.navigationController?.popViewController(animated: true)
    }
    
    func showAlert(with viewModel: ConversationErrorAlertControllerViewModel) {
        
        let alertController = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: viewModel.style)
        
        viewModel.actions.forEach {
            alertController.addAction($0)
        }
        vc?.present(alertController, animated: true)
    }
}
 struct ConversationErrorAlertControllerViewModel {
    let title: String
    let message: String?
    let style: UIAlertController.Style
    let actions: [UIAlertAction]
}
