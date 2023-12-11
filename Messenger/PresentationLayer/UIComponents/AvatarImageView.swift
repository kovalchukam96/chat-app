import UIKit

final class AvatarImageView: UIView {
    
    enum ViewModel {
        case initials(NSAttributedString)
        case image(UIImage)
    }
    
    var image: UIImage? {
        imageView.image
    }
    
    private lazy var label = UILabel()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var onlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0x30D158)
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        applyLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = frame.height / 2
        onlineView.layer.cornerRadius = onlineView.frame.height / 2
    }
    
    func configure(with viewModel: ViewModel) {
        switch viewModel {
        case .initials(let text):
            label.attributedText = text
            label.isHidden = false
            imageView.image = nil
        case .image(let image):
            imageView.image = image
            label.isHidden = true
        }
    }
    
    func setOnline(_ isOnline: Bool) {
        onlineView.isHidden = !isOnline
    }
    
    private func setupView() {
        imageView.backgroundColor = UIColor(rgb: 0xF19FB4)
    }
    
    private func applyLayout() {
        [imageView, label, onlineView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            onlineView.widthAnchor.constraint(equalToConstant: 12),
            onlineView.heightAnchor.constraint(equalToConstant: 12),
            onlineView.topAnchor.constraint(equalTo: topAnchor, constant: 0.5),
            onlineView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
