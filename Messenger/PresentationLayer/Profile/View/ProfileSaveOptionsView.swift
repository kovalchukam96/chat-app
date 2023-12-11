import UIKit

protocol ProfileSaveOptionsViewDelegate: AnyObject {
    func buttonTapped()
}

final class ProfileSaveOptionsView: UIView {
    struct ViewModel {
        let saveGCDAction: () -> Void
        let saveOperationsAction: () -> Void
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: 180, height: 88)
    }
    
    weak var delegate: ProfileSaveOptionsViewDelegate?
    
    private lazy var saveGCDButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save GCD", for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        button.titleEdgeInsets = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 0)
        button.setTitleColor(ColorPalette.Text.primary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(saveGCDTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveOperationsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save Operations", for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        button.titleEdgeInsets = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 0)
        button.setTitleColor(ColorPalette.Text.primary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(saveOperationsTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [saveGCDButton, saveOperationsButton])
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var separator = SeparatorView()
    
    private var saveGCDAction: (() -> Void)?
    private var saveOperationsAction: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        applyLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ViewModel) {
        saveGCDAction = viewModel.saveGCDAction
        saveOperationsAction = viewModel.saveOperationsAction
    }
    
    private func setupView() {
        clipsToBounds = true
        layer.cornerRadius = 12
        backgroundColor = ColorPalette.Background.contextMenu
    }
    
    private func applyLayout() {
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            saveGCDButton.heightAnchor.constraint(equalToConstant: ButtonSizeConstants.buttonHeight),
            saveGCDButton.widthAnchor.constraint(equalToConstant: ButtonSizeConstants.buttonWidth),
            saveOperationsButton.heightAnchor.constraint(equalToConstant: ButtonSizeConstants.buttonHeight),
            saveOperationsButton.widthAnchor.constraint(equalToConstant: ButtonSizeConstants.buttonWidth),
            
            separator.centerYAnchor.constraint(equalTo: centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc private func saveGCDTapped() {
        saveGCDAction?()
        delegate?.buttonTapped()
    }
    
    @objc private func saveOperationsTapped() {
        saveOperationsAction?()
        delegate?.buttonTapped()
    }
}

private extension ProfileSaveOptionsView {
    enum ButtonSizeConstants {
        static let buttonHeight: CGFloat = 44
        static let buttonWidth: CGFloat = 180
    }
}
