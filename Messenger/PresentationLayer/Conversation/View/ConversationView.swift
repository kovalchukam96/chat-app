import UIKit

protocol ConversationViewDelegate: AnyObject {
    func messageChanged(with text: String?)
}

final class ConversationView: UIView {
    
    struct ViewModel {
        let avatar: ConversationNavigationBarView.ViewModel
        let sendAction: () -> Void
    }
    
    weak var delegate: ConversationViewDelegate?
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        tableView.register(ConversationHeader.self, forHeaderFooterViewReuseIdentifier: "ConversationHeader")
        return tableView
    }()
    
    private lazy var textView: ConversationTextView = {
        let textView = ConversationTextView()
        textView.backgroundColor = ColorPalette.Background.primary
        textView.delegate = self
        return textView
    }()
    
    private(set) lazy var customNavigationBar = ConversationNavigationBarView()
    
    private var textViewBottomConstraint: NSLayoutConstraint?
    
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
    
    func updateBottomConstraint(with value: CGFloat) {
        textViewBottomConstraint?.constant = -(value - safeAreaInsets.bottom)
        layoutIfNeeded()
    }
    
    func configure(with viewModel: ViewModel) {
        customNavigationBar.configure(with: viewModel.avatar)
        textView.configure(with: .init(sendButtonAction: viewModel.sendAction))
    }
    
    private func applyLayout() {
        addSubview(customNavigationBar)
        customNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        textViewBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            customNavigationBar.topAnchor.constraint(equalTo: topAnchor),
            customNavigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            customNavigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: textView.topAnchor),
            
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupView() {
        backgroundColor = ColorPalette.Background.primary
    }
}

extension ConversationView: ConversationTextViewDelegate {
    func textChanged(with text: String?) {
        delegate?.messageChanged(with: text)
    }
}
