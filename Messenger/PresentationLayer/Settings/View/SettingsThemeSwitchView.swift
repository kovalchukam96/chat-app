import UIKit

protocol SettingsThemeSwitchViewDelegate: AnyObject {
    func buttonTapped(_ style: UIUserInterfaceStyle)
}

final class SettingsThemeSwitchView: UIView {
    struct ViewModel {
        let interfaceStyle: UIUserInterfaceStyle
        let action: () -> Void
    }
    
    weak var delegate: SettingsThemeSwitchViewDelegate?
    
    private var interfaceStyle: UIUserInterfaceStyle = .light
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 7
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ColorPalette.Element.border.cgColor
        return view
    }()
    
    private lazy var incomingBubble: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xE9E9EB)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var outComingBubble: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0x448AF7)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var themeLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorPalette.Text.primary
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var checkBox: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = UIColor(rgb: 0xAEAEB2)
        button.setImage(UIImage(named: "CheckBox_Selected"), for: .selected)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private var action: (() -> Void)?
    
    var isSelected: Bool {
        get {
            checkBox.isSelected
        }
        set {
            checkBox.isSelected = newValue
        }
    }
    
    init() {
        super.init(frame: .zero)
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ViewModel) {
        self.action = viewModel.action
        self.interfaceStyle = viewModel.interfaceStyle
        switch viewModel.interfaceStyle {
        case .dark:
            containerView.backgroundColor = .black
            incomingBubble.backgroundColor = UIColor(rgb: 0x262628)
            themeLabel.text = "Night"
        case .light:
            themeLabel.text = "Day"
        default: break
        }
    }
    
    private func applyLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        outComingBubble.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(outComingBubble)

        incomingBubble.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(incomingBubble)
        
        themeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(themeLabel)
        
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        addSubview(checkBox)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight),
            
            outComingBubble.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Constants.outComingBubbleTop
            ),
            outComingBubble.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.outComingBubbleLeading
            ),
            outComingBubble.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: Constants.outComingBubbleTrailing
            ),
            outComingBubble.heightAnchor.constraint(equalToConstant: Constants.outComingBubbleHeight),

            incomingBubble.topAnchor.constraint(
                equalTo: outComingBubble.bottomAnchor,
                constant: Constants.incomingBubbleTop
            ),
            incomingBubble.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.incomingBubbleLeading
            ),
            incomingBubble.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: Constants.incomingBubbleTrailing
            ),
            incomingBubble.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: Constants.incomingBubbleBottom
            ),
            incomingBubble.widthAnchor.constraint(
                equalToConstant: Constants.incomingBubbleWidth
            ),
            incomingBubble.heightAnchor.constraint(equalToConstant: Constants.incomingBubbleHeight),
            
            themeLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: Constants.themeLabelTop),
            themeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            themeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            checkBox.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: Constants.checkBoxTop),
            checkBox.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.checkBoxBottom),
            checkBox.centerXAnchor.constraint(equalTo: centerXAnchor),
            checkBox.heightAnchor.constraint(equalToConstant: Constants.checkBoxHeight),
            checkBox.widthAnchor.constraint(equalTo: checkBox.heightAnchor)
        ])
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        action?()
    }
}

private extension SettingsThemeSwitchView {
    enum Constants {
        static let containerViewHeight: CGFloat = 55
        static let outComingBubbleTop: CGFloat = 7
        static let outComingBubbleLeading: CGFloat = 20
        static let outComingBubbleTrailing: CGFloat = -7
        static let outComingBubbleHeight: CGFloat = 19
        static let incomingBubbleTop: CGFloat = 5
        static let incomingBubbleLeading: CGFloat = 7
        static let incomingBubbleTrailing: CGFloat = -20
        static let incomingBubbleBottom: CGFloat = -5
        static let incomingBubbleWidth: CGFloat = 52
        static let incomingBubbleHeight: CGFloat = 19
        static let themeLabelTop: CGFloat = 10
        static let checkBoxTop: CGFloat = 10
        static let checkBoxBottom: CGFloat = 0
        static let checkBoxHeight: CGFloat = 24
    }
}
