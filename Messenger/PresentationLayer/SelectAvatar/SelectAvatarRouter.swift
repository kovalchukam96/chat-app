import UIKit

protocol SelectAvatarRouterInput: AnyObject {
    func close()
    func close(with image: UIImage)
    func showAlert(with viewModel: SelectAvatarErrorAlertControllerViewModel)
}

final class SelectAvatarRouter {
    weak var vc: UIViewController?
    
    private let completion: (UIImage) -> Void
    
    init(completion: @escaping (UIImage) -> Void) {
        self.completion = completion
    }
}

extension SelectAvatarRouter: SelectAvatarRouterInput {
    func close(with image: UIImage) {
        vc?.dismiss(animated: true) { [weak self] in
            self?.completion(image)
        }
    }
    
    func close() {
        vc?.dismiss(animated: true)
    }
    
    func showAlert(with viewModel: SelectAvatarErrorAlertControllerViewModel) {
        
        let alertController = UIAlertController(
            title: viewModel.title,
            message: viewModel.message,
            preferredStyle: viewModel.style
        )
        
        viewModel.actions.forEach {
            alertController.addAction($0)
        }
        vc?.present(alertController, animated: true)
    }
    
}

struct SelectAvatarErrorAlertControllerViewModel {
   let title: String
   let message: String?
   let style: UIAlertController.Style
   let actions: [UIAlertAction]
}
