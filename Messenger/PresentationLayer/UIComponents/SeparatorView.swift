import UIKit

final class SeparatorView: UIView {

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.Element.separator
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyLayout() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
