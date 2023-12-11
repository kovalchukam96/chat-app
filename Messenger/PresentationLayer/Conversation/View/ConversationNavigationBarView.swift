import UIKit

final class ConversationNavigationBarView: UIView {
    
    struct ViewModel {
        let avatar: AvatarImageView.ViewModel
        let name: String
        let action: () -> Void
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.Background.alternative
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = UIColor(rgb: 0x007AFF)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var avatar = AvatarImageView()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = ColorPalette.Text.primary
        return label
    }()
    
    private var action: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ViewModel) {
        self.action = viewModel.action
        avatar.configure(with: viewModel.avatar)
        nameLabel.text = viewModel.name
    }
    
    private func applyLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backButton)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(avatar)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.containerTop),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            backButton.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: Constants.backButtonBottom
            ),
            backButton.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.backButtonLeading
            ),
            backButton.widthAnchor.constraint(equalToConstant: Constants.backButtonWidth),
            backButton.heightAnchor.constraint(equalToConstant: Constants.backButtonHeight),
            
            avatar.heightAnchor.constraint(equalToConstant: Constants.avatarHeight),
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor),
            avatar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.containerTop),
            avatar.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: Constants.nameLabelTop),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: Constants.nameLabelBottom)
        ])
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        action?()
    }
}

private extension ConversationNavigationBarView {
    enum Constants {
        static let containerTop: CGFloat = 2
        static let backButtonBottom: CGFloat = -44
        static let backButtonLeading: CGFloat = 18
        static let backButtonWidth: CGFloat = 12
        static let backButtonHeight: CGFloat = 20
        static let avatarHeight: CGFloat = 50
        static let nameLabelBottom: CGFloat = -20
        static let nameLabelTop: CGFloat = 5
    }
}
