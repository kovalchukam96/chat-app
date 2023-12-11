import UIKit

final class ConversationHeader: UITableViewHeaderFooterView {
    
    typealias ViewModel = String
    
    private(set) lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = ColorPalette.Text.secondary
        label.textAlignment = .center
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        applyLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ViewModel) {
        dateLabel.text = viewModel
    }

    private func applyLayout() {
        contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.dateLabelTop),
            dateLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.dateLabelLeading
            ),
            dateLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: Constants.dateLabelTrailing
            ),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.dateLabelBottom)
        ])

    }

}

private extension ConversationHeader {
    enum Constants {
        static let dateLabelTop: CGFloat = 12
        static let dateLabelLeading: CGFloat = 20
        static let dateLabelTrailing: CGFloat = -10
        static let dateLabelBottom: CGFloat = -12
    }
}
