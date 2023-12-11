import Combine
import UIKit

final class ProfileDataEditView: UIView {
    struct ViewModel {
        let labelName: String
        let text: CurrentValueSubject<String?, Never>
        let placeholder: String
    }
    private var textSubscription: Cancellable?
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = ColorPalette.Text.primary
        return label
    }()
    
    private lazy var textField = UITextField()
    
    init() {
        super.init(frame: .zero)
        applyLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    func configure(with viewModel: ViewModel) {
        infoLabel.text = viewModel.labelName
        textSubscription = textField.textPublisher.assign(to: \.value, on: viewModel.text)
        textField.text = viewModel.text.value
        textField.placeholder = viewModel.placeholder
    }
    
    private func setupView() {
        backgroundColor = ColorPalette.Background.primary
    }
    
    private func applyLayout() {
  
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(infoLabel)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.infoLabelTop),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.infoLabelLeading),
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.infoLabelBottom),
            infoLabel.widthAnchor.constraint(equalToConstant: Constants.infoLabelWidth),
            infoLabel.heightAnchor.constraint(equalToConstant: Constants.infoLabelHeight),
            
            textField.topAnchor.constraint(equalTo: infoLabel.topAnchor),
            textField.leadingAnchor.constraint(equalTo: infoLabel.trailingAnchor, constant: Constants.textFieldLeading),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.textFieldTrailing),
            textField.bottomAnchor.constraint(equalTo: infoLabel.bottomAnchor)
        ])
    }

}

extension UITextField {
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { notification in
                (notification.object as? UITextField)?.text
            }
            .eraseToAnyPublisher()
    }
}

private extension ProfileDataEditView {
    enum Constants {
        static let infoLabelTop: CGFloat = 11
        static let infoLabelLeading: CGFloat = 16
        static let infoLabelBottom: CGFloat = -11
        static let infoLabelWidth: CGFloat = 96
        static let infoLabelHeight: CGFloat = 22
        static let textFieldLeading: CGFloat = 8
        static let textFieldTrailing: CGFloat = -36
    }
}
