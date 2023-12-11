import UIKit

final class ProfileView: UIView {
    
    private var timer: Timer?
    
    private lazy var profileImageView = AvatarImageView()
    
    private(set) lazy var addPhotoButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(UIColor(rgb: 0x007AFF), for: .normal)
        button.setTitle("Add photo", for: .normal)
        button.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        label.textAlignment = .left
        label.text = "My profile"
        label.textColor = ColorPalette.Text.primary
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.textColor = ColorPalette.Text.primary
        label.numberOfLines = 0
        label.accessibilityIdentifier = "nameField"
        return label
    }()
    
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = ColorPalette.Text.secondary
        label.numberOfLines = 0
        label.accessibilityIdentifier = "bioField"
        return label
    }()
    
    private lazy var nameEditField: ProfileDataEditView = {
        let view = ProfileDataEditView()
        return view
    }()
    
    private lazy var bioEditField: ProfileDataEditView = {
        let view = ProfileDataEditView()
        return view
    }()
    
    private lazy var topSeparator: SeparatorView = {
        let view = SeparatorView()
        view.isHidden = true
        return view
    }()
    
    private lazy var middleSeparator: SeparatorView = {
        let view = SeparatorView()
        view.isHidden = true
        return view
    }()
    
    private lazy var  bottomSeparator: SeparatorView = {
        let view = SeparatorView()
        view.isHidden = true
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                profileImageView,
                addPhotoButton,
                nameLabel,
                bioLabel,
                editButton,
                topSeparator,
                nameEditField,
                middleSeparator,
                bioEditField,
                bottomSeparator
            ]
        )
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }()
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Edit Profile", for: .normal)
        button.backgroundColor = UIColor(rgb: 0x007AFF)
        button.layer.cornerRadius = 14
        button.widthAnchor.constraint(equalToConstant: Constants.editButtonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: Constants.editButtonHeight).isActive = true
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        button.addGestureRecognizer(longPressGesture)
        return button
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(UIColor(rgb: 0x007AFF), for: .normal)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(UIColor(rgb: 0x007AFF), for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var savingIndicator = UIActivityIndicatorView()
    
    private var addPhotoAction: (() -> Void)?
    private var editButtonAction: (() -> Void)?
    private var saveButtonAction: (() -> Void)?
    private var cancelButtonAction: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        applyLayout()
        setupView()
        observeKeyboard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ViewModel) {
        switch viewModel {
        case .initial(let initialModel):
            backgroundColor = ColorPalette.Background.primary
            nameLabel.text = initialModel.name
            bioLabel.text = initialModel.info
            profileImageView.configure(with: initialModel.avatar)
            self.addPhotoAction = initialModel.addPhotoAction
            nameEditField.isHidden = true
            bioEditField.isHidden = true
            self.editButtonAction = initialModel.rightBarButtonAction
            nameLabel.isHidden = false
            bioLabel.isHidden = false
            nameEditField.resignFirstResponder()
            bioEditField.resignFirstResponder()
            addPhotoButton.isUserInteractionEnabled = true
            topSeparator.isHidden = true
            middleSeparator.isHidden = true
            bottomSeparator.isHidden = true
            editButton.isHidden = false
            titleLabel.isHidden = false
            
        case .edit(let editModel):
            backgroundColor = ColorPalette.Background.alternative
            nameLabel.isHidden = true
            bioLabel.isHidden = true
            nameEditField.isHidden = false
            nameEditField.isUserInteractionEnabled = true
            bioEditField.isHidden = false
            bioEditField.isUserInteractionEnabled = true
            addPhotoButton.isUserInteractionEnabled = true
            nameEditField.configure(with: editModel.name)
            bioEditField.configure(with: editModel.info)
            nameEditField.becomeFirstResponder()
            self.addPhotoAction = editModel.addPhotoAction
            self.cancelButtonAction = editModel.leftBarButtonAction
            self.saveButtonAction = editModel.rightBarButtonAction
            topSeparator.isHidden = false
            middleSeparator.isHidden = false
            bottomSeparator.isHidden = false
            editButton.isHidden = true
            titleLabel.isHidden = true
            
        case .saving:
            nameLabel.isHidden = true
            bioLabel.isHidden = true
            nameEditField.isHidden = false
            nameEditField.isUserInteractionEnabled = false
            bioEditField.isHidden = false
            bioEditField.isUserInteractionEnabled = false
            addPhotoButton.isUserInteractionEnabled = false
            savingIndicator.startAnimating()
            editButton.isHidden = true
            titleLabel.isHidden = true
        }
    }
    
    func updateAvatar(image: UIImage) {
        profileImageView.configure(with: .image(image))
    }
    
    private func updateBottomConstraint(with value: CGFloat) {
        scrollView.contentInset.bottom = value
    }
    
    private func observeKeyboard() {
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
    }
    
    private func setupView() {
        backgroundColor = ColorPalette.Background.primary
    }
    
    private func applyLayout() {
        
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.defaultInset),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.defaultInset),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.stackViewTop),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -DefaultInset.inset),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            topSeparator.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            middleSeparator.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: DefaultInset.inset),
            bottomSeparator.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.profileImageViewSquare),
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.profileImageViewSquare),
            
            addPhotoButton.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            
            nameEditField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            nameEditField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            bioEditField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            bioEditField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            
        ])
        
        stackView.setCustomSpacing(24, after: profileImageView)
        stackView.setCustomSpacing(24, after: addPhotoButton)
        stackView.setCustomSpacing(10, after: nameLabel)
        stackView.setCustomSpacing(24, after: bioLabel)
        stackView.setCustomSpacing(0, after: nameEditField)
        stackView.setCustomSpacing(0, after: bioEditField)
        stackView.setCustomSpacing(0, after: topSeparator)
        stackView.setCustomSpacing(0, after: middleSeparator)
    }
    
    @objc func editButtonTapped() {
        editButtonAction?()
    }
    
    @objc func saveButtonTapped() {
        saveButtonAction?()
    }
    
    @objc func addPhotoTapped() {
        addPhotoAction?()
    }
    
    @objc func cancelButtonTapped() {
        cancelButtonAction?()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = convert(keyboardScreenEndFrame, from: window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            updateBottomConstraint(with: .zero)
        } else {
            updateBottomConstraint(with: keyboardViewEndFrame.height)
        }
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .ended else { return }
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
                self?.animateButton()
            }
            timer?.fire()
        } else {
            timer?.invalidate()
            timer = nil
            
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut]) {
                self.editButton.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc private func animateButton() {
        UIView.animateKeyframes(
            withDuration: 0.3,
            delay: 0,
            options: [.calculationModeLinear, .allowUserInteraction],
            animations: {
                let rotationClockwise = CGAffineTransform(rotationAngle: CGFloat.pi / 10)
                let rotationCounterClockwise = CGAffineTransform(rotationAngle: -CGFloat.pi / 10)
                let translationRightUp = CGAffineTransform(translationX: 5, y: -5)
                let translationLeftDown = CGAffineTransform(translationX: -5, y: 10)
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1 / 4, animations: {
                    self.editButton.transform = rotationClockwise.concatenating(translationRightUp)
                })
                UIView.addKeyframe(withRelativeStartTime: 1 / 4, relativeDuration: 1 / 4, animations: {
                    self.editButton.transform = rotationCounterClockwise.concatenating(translationLeftDown)
                })
                UIView.addKeyframe(withRelativeStartTime: 1 / 2, relativeDuration: 1 / 4, animations: {
                    self.editButton.transform = rotationClockwise.concatenating(translationLeftDown)
                })
                UIView.addKeyframe(withRelativeStartTime: 3 / 4, relativeDuration: 1 / 4, animations: {
                    self.editButton.transform = rotationCounterClockwise.concatenating(translationRightUp)
                })
            }, completion: nil)
        
    }
    
}

private extension ProfileView {
    enum Constants {
        static let defaultInset: CGFloat = 16
        static let profileImageViewSquare: CGFloat = 150
        static let stackViewTop: CGFloat = 47
        static let editButtonWidth: CGFloat = 320
        static let editButtonHeight: CGFloat = 50
    }
}
