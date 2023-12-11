import UIKit

protocol ConversationTextViewDelegate: AnyObject {
    func textChanged(with text: String?)
}

final class ConversationTextView: UIView {
    
    struct ViewModel {
        let sendButtonAction: () -> Void
    }
    
    weak var delegate: ConversationTextViewDelegate?
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.font = .systemFont(ofSize: 17)
        textView.textContainerInset = .zero
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Type message"
        label.textColor = ColorPalette.Text.secondary.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "SendButton"), for: .normal)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.layer.borderColor = ColorPalette.Element.border.withAlphaComponent(0.36).cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private var sendButtonAction: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        applyLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ViewModel) {
        self.sendButtonAction = viewModel.sendButtonAction
    }
    
    private func applyLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textView)
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholderLabel)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.containerTop),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.containerLeading),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.containerTrailing),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.containerBottom),
            
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.textViewTop),
            textView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.textViewLeading
            ),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: Constants.textViewBottom),
            textView.heightAnchor.constraint(equalToConstant: Constants.textViewHeight),
            
            sendButton.leadingAnchor.constraint(
                equalTo: textView.trailingAnchor,
                constant: Constants.sendButtonLeading
            ),
            sendButton.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: Constants.sendButtonTrailing
            ),
            sendButton.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: Constants.sendButtonBottom
            ),
            sendButton.widthAnchor.constraint(equalToConstant: Constants.sendButtonWidth),
            sendButton.heightAnchor.constraint(equalTo: sendButton.widthAnchor),
            
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor)
        ])
    }
    
    private func setupView() {
        backgroundColor = ColorPalette.Background.primary
    }
    
    @objc private func sendButtonTapped() {
        sendButtonAction?()
        textView.text = nil
    }
    
}

extension ConversationTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textChanged(with: textView.text)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

private extension ConversationTextView {
    enum Constants {
        static let containerTop: CGFloat = 8
        static let containerLeading: CGFloat = 8
        static let containerTrailing: CGFloat = -8
        static let containerBottom: CGFloat = -8
        static let textViewTop: CGFloat = 6
        static let textViewLeading: CGFloat = 12
        static let textViewBottom: CGFloat = -6
        static let textViewHeight: CGFloat = 24
        static let sendButtonLeading: CGFloat = -2
        static let sendButtonTrailing: CGFloat = -4
        static let sendButtonBottom: CGFloat = -4
        static let sendButtonWidth: CGFloat = 28
    }
}
