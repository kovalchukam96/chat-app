import UIKit

final class ConversationsListCell: UITableViewCell, ConfigurableViewProtocol {
    
    struct ViewModel {
        let channelName: String
        let message: String?
        let date: String?
        let avatar: AvatarImageView.ViewModel
        let hasUnreadMessages: Bool
        let isLast: Bool
        let deleteAction: UIContextualAction
        let action: () -> Void
    }
    
    private lazy var channelNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = ColorPalette.Text.primary
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = ColorPalette.Text.primary
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = ColorPalette.Text.secondary
        return label
    }()
    
    private lazy var disclosureIndicatorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = ColorPalette.Text.secondary
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.6)
        return view
    }()
    
    private lazy var avatarImageView = AvatarImageView()
    
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
        channelNameLabel.text = viewModel.channelName
        dateLabel.text = viewModel.date
        avatarImageView.configure(with: viewModel.avatar)
        if viewModel.message == nil {
            messageLabel.text = "No messages yet"
            messageLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 15)
            messageLabel.textColor = ColorPalette.Text.secondary
            dateLabel.text = ""
        } else {
            if viewModel.hasUnreadMessages {
                messageLabel.text = viewModel.message
                messageLabel.font = .boldSystemFont(ofSize: 15)
                messageLabel.textColor = ColorPalette.Text.primary
            } else {
                messageLabel.font = .systemFont(ofSize: 15)
                messageLabel.textColor = ColorPalette.Text.secondary
                messageLabel.text = viewModel.message
            }
        }
      
        separatorView.isHidden = viewModel.isLast
        
    }
    
    private func applyLayout() {
        selectionStyle = .none
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImageView)
        
        channelNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(channelNameLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        disclosureIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(disclosureIndicatorImageView)
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.avatarLeading
            ),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),
            
            channelNameLabel.leadingAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: Constants.channelNameLabelLeading
            ),
            channelNameLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.channelNameLabelTop
            ),
            channelNameLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: dateLabel.leadingAnchor,
                constant: -Constants.spaceBetweenLabels
            ),
            
            dateLabel.topAnchor.constraint(equalTo: channelNameLabel.topAnchor),
            dateLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.dateLabelTrailing
            ),
            
            messageLabel.leadingAnchor.constraint(equalTo: channelNameLabel.leadingAnchor),
            messageLabel.topAnchor.constraint(equalTo: channelNameLabel.bottomAnchor),
            messageLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.messageLabelTrailing
            ),
            messageLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.messageLabelBottom
            ),
            
            disclosureIndicatorImageView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            disclosureIndicatorImageView.leadingAnchor.constraint(
                equalTo: dateLabel.trailingAnchor,
                constant: Constants.disclosureLeading
            ),

            disclosureIndicatorImageView.widthAnchor.constraint(equalToConstant: Constants.disclosureWidth),
            disclosureIndicatorImageView.heightAnchor.constraint(equalToConstant: Constants.disclosureHeight),
            
            separatorView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight)
        ])
    }
}

enum DefaultInset {
    static let inset: CGFloat = 16
}

private extension ConversationsListCell {
    enum Constants {
        static let imageSize: CGFloat = 45
        static let avatarLeading: CGFloat = 16
        static let channelNameLabelLeading: CGFloat = 12
        static let channelNameLabelTop: CGFloat = 17
        static let spaceBetweenLabels: CGFloat = 8
        static let dateLabelTrailing: CGFloat = 16
        static let messageLabelTrailing: CGFloat = 16
        static let messageLabelBottom: CGFloat = 17
        static let disclosureLeading: CGFloat = 8
        static let disclosureTrailing: CGFloat = 16
        static let disclosureWidth: CGFloat = 6.42
        static let disclosureHeight: CGFloat = 11
        static let separatorHeight: CGFloat = 1
    }
}
