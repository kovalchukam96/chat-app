import UIKit

protocol SelectAvatarViewInput: AnyObject {
    func displayData(with viewModels: [URL])
}

final class SelectAvatarViewController: UIViewController {
    
    var presenter: SelectAvatarViewOutput? {
        didSet {
            collectionManager.presenter = presenter
        }
    }
    
    private let collectionManager: SelectAvatarCollectionManager
    
    private lazy var contentView = SelectAvatarView(collectionViewManager: collectionManager)
    
    init(collectionManager: SelectAvatarCollectionManager) {
        self.collectionManager = collectionManager
        super.init(nibName: nil, bundle: nil)
        collectionManager.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        presenter?.viewLoaded()
    }
    
    private func configureNavigationBar() {
        title = "Select Photo"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
                   title: "Cancel",
                   style: .plain,
                   target: self,
                   action: #selector(cancelTapped)
                   )
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
}

extension SelectAvatarViewController: SelectAvatarViewInput {
    func displayData(with viewModels: [URL]) {
        contentView.activityIndicator.isHidden = true
        collectionManager.viewModels = viewModels
        contentView.collectionView.reloadData()
    }
}

extension SelectAvatarViewController: SelectAvatarCollectionManagerDelegate {
    func didScrollToBottom() {
        contentView.activityIndicator.isHidden = false
        presenter?.didScrollToBottom()
    }
}
