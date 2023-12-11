import UIKit

protocol ConversationsListViewDelegate: AnyObject {
    func refreshView()
}

final class ConversationsListView: UIView {
    
    struct ViewModel {
        let items: [ConversationsListCell.ViewModel]
    }
    
    weak var delegate: ConversationsListViewDelegate?
    
    private(set) lazy var pullToRefresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        return refresh
    }()
    
    private(set) lazy var avatar = AvatarImageView()
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.refreshControl = pullToRefresh
        tableView.separatorStyle = .none
        tableView.register(ConversationsListCell.self, forCellReuseIdentifier: "ConversationsListCell")
        return tableView
    }()
    
    init(tableManager: UITableViewDataSource & UITableViewDelegate) {
        super.init(frame: .zero)
        tableView.dataSource = tableManager
        tableView.delegate = tableManager
        applyLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyLayout() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            avatar.widthAnchor.constraint(equalToConstant: Constants.avatarWidth),
            avatar.heightAnchor.constraint(equalToConstant: Constants.avatarHeight)
            
        ])
    }
    
    private func setupView() {
        backgroundColor = ColorPalette.Background.primary
    }
    
    @objc private func refreshPulled() {
        delegate?.refreshView()
    }
    
}

private extension ConversationsListView {
    enum Constants {
        static let avatarHeight: CGFloat = 32
        static let avatarWidth: CGFloat = 32
    }
}
