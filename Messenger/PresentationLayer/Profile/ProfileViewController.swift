import UIKit

protocol ProfileViewInput: AnyObject {
    func displayData(with viewmodel: ProfileView.ViewModel)
    func updateAvatar(image: UIImage)
    func updateRightBarButton()
}

final class ProfileViewController: UIViewController {
    var presenter: ProfileViewOutput?
    
    private lazy var cancelButton = UIBarButtonItem(customView: contentView.cancelButton)
    private lazy var saveButton = UIBarButtonItem(customView: contentView.saveButton)
    private lazy var savingIndicator = UIBarButtonItem(customView: contentView.savingIndicator)
    
    private lazy var contentView: ProfileView = {
        let view = ProfileView()
        return view
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
}

// MARK: - ProfileViewInput

extension ProfileViewController: ProfileViewInput {
    func updateRightBarButton() {
        navigationItem.rightBarButtonItem = saveButton
    }
    
    func updateAvatar(image: UIImage) {
        contentView.updateAvatar(image: image)
    }
    
    func displayData(with viewModel: ProfileView.ViewModel) {
        switch viewModel {
            
        case .initial:
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = nil
            title = nil
        case .edit:
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = saveButton
            title = "Edit Profile"
        case .saving:
            navigationItem.rightBarButtonItem = savingIndicator
        }

        contentView.configure(with: viewModel)
    }
}
