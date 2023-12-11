import UIKit

protocol ConversationsListViewInput: AnyObject {
    func updateAvatar(with viewModel: AvatarImageView.ViewModel)
    func beginUpdates()
    func endUpdates()
    func insertRow(at indexPath: IndexPath)
    func deleteRow(at indexPath: IndexPath)
    func reloadRow(at indexPath: IndexPath)
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath)
}

final class ConversationsListViewController: UIViewController {
    var presenter: ConversationsListViewOutput? {
        didSet {
            tableManager.presenter = presenter
        }
    }
    private let tableManager = ConversationsListTableManager()
    
    private lazy var contentView = ConversationsListView(tableManager: tableManager)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = contentView
        contentView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        presenter?.viewLoaded()
        tableManager.tableView = contentView.tableView
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.layoutMargins.left = 16
        navigationController?.navigationBar.layoutMargins.right = 16
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add Channel",
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 34)
        ]
        title = "Channels"
        if let navigationController = navigationController {
            navigationItem.scrollEdgeAppearance = navigationController.navigationBar.standardAppearance
            navigationController.view.backgroundColor = ColorPalette.Background.primary
            navigationController.navigationBar.backgroundColor = ColorPalette.Background.alternative
            navigationController.navigationBar.isTranslucent = true
        }
    }
    
    @objc private func settingsTapped() {
        presenter?.addChannelTapped()
    }
}

// MARK: - ConversationsListViewInput

extension ConversationsListViewController: ConversationsListViewInput {
    func beginUpdates() {
        tableManager.beginUpdates()
    }
    
    func endUpdates() {
        tableManager.endUpdates()
        contentView.pullToRefresh.endRefreshing()
    }
    
    func insertRow(at indexPath: IndexPath) {
        tableManager.insertRow(at: indexPath)
    }
    
    func deleteRow(at indexPath: IndexPath) {
        tableManager.deleteRow(at: indexPath)
    }
    
    func reloadRow(at indexPath: IndexPath) {
        tableManager.reloadRow(at: indexPath)
    }
    
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        tableManager.moveRow(at: indexPath, to: newIndexPath)
    }
    
    func updateAvatar(with viewModel: AvatarImageView.ViewModel) {
        contentView.avatar.configure(with: viewModel)
    }
    
}

extension ConversationsListViewController: ConversationsListViewDelegate {
    func refreshView() {
        presenter?.reloadData()
    }
}
