import UIKit

protocol SettingsViewDelegate: SettingsThemeSwitchViewDelegate {}

final class SettingsView: UIView {
    
    struct ViewModel {
        let dayMode: SettingsThemeSwitchView.ViewModel
        let nightMode: SettingsThemeSwitchView.ViewModel
    }
    
    weak var delegate: SettingsViewDelegate? {
        didSet {
            dayModeSwitch.delegate = delegate
            nightModeSwitch.delegate = delegate
        }
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.Background.primary
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var dayModeSwitch = SettingsThemeSwitchView()
    
    private lazy var nightModeSwitch = SettingsThemeSwitchView()
    
    init() {
        super.init(frame: .zero)
        applyLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ViewModel) {
        dayModeSwitch.configure(with: viewModel.dayMode)
        nightModeSwitch.configure(with: viewModel.nightMode)
    }
    
    func updateState(with style: UIUserInterfaceStyle) {
        switch style {
        case .light:
            dayModeSwitch.isSelected = true
            nightModeSwitch.isSelected = false
        case .dark:
            dayModeSwitch.isSelected = false
            nightModeSwitch.isSelected = true
        default: break
        }
    }
    
    private func setupView() {
        backgroundColor = ColorPalette.Background.alternative
    }
    
    private func applyLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        dayModeSwitch.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dayModeSwitch)

        nightModeSwitch.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nightModeSwitch)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: Constants.containerViewTop
            ),
            containerView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.containerViewLeading
            ),
            containerView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: Constants.containerViewTrailing
            ),
            
            dayModeSwitch.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Constants.switchTopBottomMargin),
            dayModeSwitch.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dayModeSwitch.trailingAnchor.constraint(equalTo: centerXAnchor),
            dayModeSwitch.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -Constants.switchTopBottomMargin
            ),
            
            nightModeSwitch.topAnchor.constraint(equalTo: dayModeSwitch.topAnchor),
            nightModeSwitch.leadingAnchor.constraint(equalTo: centerXAnchor),
            nightModeSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nightModeSwitch.bottomAnchor.constraint(equalTo: dayModeSwitch.bottomAnchor)
        ])
    }
    
}

private extension SettingsView {
    enum Constants {
        static let containerViewTop: CGFloat = 16
        static let containerViewLeading: CGFloat = 16
        static let containerViewTrailing: CGFloat = -16
        static let switchTopBottomMargin: CGFloat = 24
    }
}
