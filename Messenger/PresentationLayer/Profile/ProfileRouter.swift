import UIKit

protocol ProfileRouterInput: AnyObject {
    func close()
    func showAlert(with viewModel: AlertControllerViewModel)
    func showCamera(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate)
    func showLibrary(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate)
    func showDownload(completion: @escaping (UIImage) -> Void)
}

final class ProfileRouter {
    weak var vc: UIViewController?
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
}

// MARK: - ProfileRouterInput

extension ProfileRouter: ProfileRouterInput {
    func showCamera(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = delegate
        vc?.present(imagePicker, animated: true)
    }
    
    func showLibrary(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = delegate
        vc?.present(imagePicker, animated: true)
    }
    
    func showDownload(completion: @escaping (UIImage) -> Void) {
        let selectAvatarVC = SelectAvatarFactory(
            container: container
        )
            .build(completion: completion)
        let selectAvatarNC = UINavigationController(rootViewController: selectAvatarVC)
        vc?.present(selectAvatarNC, animated: true)
    }
    
    func close() {
        vc?.dismiss(animated: true)
    }
    
    func showAlert(with viewModel: AlertControllerViewModel) {
        
        let alertController = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: viewModel.style)
        
        viewModel.actions.forEach {
            alertController.addAction($0)
        }
        vc?.present(alertController, animated: true)
    }
}

struct AlertControllerViewModel {
    let title: String
    let message: String?
    let style: UIAlertController.Style
    let actions: [UIAlertAction]
}
