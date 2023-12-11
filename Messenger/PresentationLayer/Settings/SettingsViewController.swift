import UIKit

protocol SettingsViewInput: AnyObject {
    func displayData(with viewModel: SettingsView.ViewModel)
    func updateState(with style: UIUserInterfaceStyle)
}
// Примеры возникновения retain cycle описал в SettingsPresenter
final class SettingsViewController: UIViewController {
    var presenter: SettingsViewOutput?
    
    private lazy var contentView = SettingsView()

    init() {
        super.init(nibName: nil, bundle: nil)
        contentView.delegate = self
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
        navigationItem.largeTitleDisplayMode = .never
        title = "Settings"
        navigationItem.leftBarButtonItem?.title = "Back"
    }
    
}

extension SettingsViewController: SettingsViewInput {
    func updateState(with style: UIUserInterfaceStyle) {
        contentView.updateState(with: style)
    }
    
    func displayData(with viewModel: SettingsView.ViewModel) {
        contentView.configure(with: viewModel)
    }
}

extension SettingsViewController: SettingsViewDelegate {
    func buttonTapped(_ style: UIUserInterfaceStyle) {
        presenter?.updateUserInterfaceStyle(with: style)
    }
}
