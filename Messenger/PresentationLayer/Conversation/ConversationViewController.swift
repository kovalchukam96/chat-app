import UIKit

protocol ConversationViewInput: AnyObject {
    func configure(with viewModel: ConversationView.ViewModel)
    func beginUpdates()
    func endUpdates()
    func insertRow(at indexPath: IndexPath)
    func deleteRow(at indexPath: IndexPath)
    func reloadRow(at indexPath: IndexPath)
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath)
}

final class ConversationViewController: UIViewController {
    var presenter: ConversationViewOutput? {
        didSet {
            tableManager.presenter = presenter
        }
    }
    
    private let tableManager = ConversationTableManager()
    
    private lazy var contentView: ConversationView = {
        let view = ConversationView(tableManager: tableManager)
        view.delegate = self
        return view
    }()
    
    deinit {
            NotificationCenter.default.removeObserver(
                self,
                name: UIResponder.keyboardWillHideNotification,
                object: self
            )

            NotificationCenter.default.removeObserver(
                self,
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: self
            )
        }

    override func loadView() {
        view = contentView
        tableManager.tableView = contentView.tableView
        contentView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        presenter?.viewLoaded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
       
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            contentView.updateBottomConstraint(with: .zero)
        } else {
            contentView.updateBottomConstraint(with: keyboardViewEndFrame.height)
            tableManager.scrollToBottom()
        }
    }
    
}

// MARK: - ConversationViewInput

extension ConversationViewController: ConversationViewInput {
    func configure(with viewModel: ConversationView.ViewModel) {
        tableManager.tableView = contentView.tableView
        contentView.configure(with: viewModel)
    }
    
    func beginUpdates() {
        tableManager.beginUpdates()
    }
    
    func endUpdates() {
        tableManager.endUpdates()
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

}

extension ConversationViewController: ConversationViewDelegate {
    
    func messageChanged(with text: String?) {
        presenter?.updateMessage(with: text)
    }
}
