import UIKit

final class ConversationCell: UITableViewCell, ConfigurableViewProtocol {
    
    struct ViewModel {
        let name: String
        let message: String
        let date: String
        let isOutcoming: Bool
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = ColorPalette.Text.secondary
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        return label
    }()
    
    private lazy var bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private var incomeBubbleViewConstraints = [NSLayoutConstraint]()
    
    private var outcomeBubbleViewConstraints = [NSLayoutConstraint]()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: ViewModel) {
        if viewModel.isOutcoming {
            nameLabel.isHidden = true
            bubbleView.backgroundColor = UIColor(rgb: 0x448AF7)
            messageLabel.text = viewModel.message
            messageLabel.textColor = .white
            dateLabel.text = viewModel.date
            dateLabel.textColor = UIColor(rgb: 0xEBEBF5)
            incomeBubbleViewConstraints.forEach {
                $0.isActive = false
            }
            outcomeBubbleViewConstraints.forEach {
                $0.isActive = true
            }
        } else {
            nameLabel.text = viewModel.name
            bubbleView.backgroundColor = ColorPalette.Background.incomingBubble
            messageLabel.text = viewModel.message
            messageLabel.textColor = ColorPalette.Text.secondary
            dateLabel.text = viewModel.date
            dateLabel.textColor = ColorPalette.Text.secondary
            outcomeBubbleViewConstraints.forEach {
                $0.isActive = false
            }
            incomeBubbleViewConstraints.forEach {
                $0.isActive = true
            }
        }
    }
    
    private func applyLayout() {
        selectionStyle = .none
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(dateLabel)
        let outcomeBubbleViewLeadingConstraint = bubbleView.leadingAnchor.constraint(
            greaterThanOrEqualTo: contentView.leadingAnchor,
            constant: contentView.bounds.width / 4
        )
        let outcomeBubbleViewTrailingConstraint = bubbleView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -20
        )
        let incomeBubbleViewLeadingConstraint = bubbleView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 20
        )
        let incomeBubbleViewTrailingConstraint = bubbleView.trailingAnchor.constraint(
            lessThanOrEqualTo: contentView.trailingAnchor,
            constant: -contentView.bounds.width / 4
        )
        outcomeBubbleViewConstraints.append(
            contentsOf: [outcomeBubbleViewTrailingConstraint, outcomeBubbleViewLeadingConstraint]
        )
        incomeBubbleViewConstraints.append(
            contentsOf: [incomeBubbleViewTrailingConstraint, incomeBubbleViewLeadingConstraint]
        )
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.nameLabelTop),
            nameLabel.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            
            bubbleView.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: LayoutConstants.bubbleViewTopToNameLabel
            ),
            bubbleView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: LayoutConstants.bubbleViewBottom
            ),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: LayoutConstants.messageLabelTop),
            messageLabel.leadingAnchor.constraint(
                equalTo: bubbleView.leadingAnchor,
                constant: LayoutConstants.messageLabelLeading
            ),
            messageLabel.trailingAnchor.constraint(
                equalTo: dateLabel.leadingAnchor,
                constant: LayoutConstants.messageLabelTrailingToDateLabel
            ),
            messageLabel.bottomAnchor.constraint(
                equalTo: bubbleView.bottomAnchor,
                constant: LayoutConstants.messageLabelBottom
            ),
            
            dateLabel.trailingAnchor.constraint(
                equalTo: bubbleView.trailingAnchor,
                constant: LayoutConstants.dateLabelTrailing
            ),
            dateLabel.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor)
        
        ])
    }
    
}

private extension ConversationCell {
    
    enum LayoutConstants {
        static let nameLabelTop: CGFloat = 2
        static let bubbleViewTopToNameLabel: CGFloat = 5
        static let bubbleViewBottom: CGFloat = -2
        static let messageLabelTop: CGFloat = 6
        static let messageLabelLeading: CGFloat = 12
        static let messageLabelTrailingToDateLabel: CGFloat = -4
        static let messageLabelBottom: CGFloat = -6
        static let dateLabelTrailing: CGFloat = -12
    }
    
}
