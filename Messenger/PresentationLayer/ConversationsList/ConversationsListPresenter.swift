import Combine
import UIKit
import TFSChatTransport
import CoreData

protocol ConversationsListViewOutput: AnyObject {
    func viewLoaded()
    func addChannelTapped()
    func reloadData()
    func numberOfRows(in section: Int) -> Int
    func viewModel(for indexPath: IndexPath) -> ConversationsListCell.ViewModel
}

final class ConversationsListPresenter: NSObject {
    private weak var view: ConversationsListViewInput?
    private let router: ConversationsListRouterInput
    private let interactor: ConversationsListInteractorInput
    private let dateFormatter = MessengerDateFormatter()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var addChannelText = CurrentValueSubject<String?, Never>("")
    
    init(
        view: ConversationsListViewInput,
        router: ConversationsListRouterInput,
        interactor: ConversationsListInteractorInput
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
   private func convertChannelToViewModel(with channel: DBChannel, isLast: Bool) -> ConversationsListCell.ViewModel {
        let date: String?
        let name = channel.name ?? ""
        if let lastActivity = channel.lastActivity {
            date = dateFormatter.string(from: lastActivity)
        } else {
            date = nil
        }
        let attributedInitials = NSAttributedString(
            string: name.createInitials(),
            attributes: [.font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: UIColor.white]
        )
        let avatar = AvatarImageView.ViewModel.initials(attributedInitials)
       
       let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
           guard let channelID = channel.id else { return }
           self?.interactor.deleteChannel(id: channelID)
       }
        
        return ConversationsListCell.ViewModel(
            channelName: name,
            message: channel.lastMessage,
            date: date,
            avatar: avatar,
            hasUnreadMessages: false,
            isLast: isLast,
            deleteAction: deleteAction
        ) { [weak self] in
            guard let channelID = channel.id else { return }
            self?.router.openConversation(avatar: avatar, channelID: channelID, name: name)
        }
    }

    private func loadAvatar() {
        interactor.loadProfile()
        interactor.profile.sink { [weak self] profile in
            guard let self = self else {
                return
            }
            if let image = profile?.avatar {
                self.view?.updateAvatar(with: .image(image.image))
            } else if let name = profile?.name {
                let initials = name.createInitials()
                let attributedInitials = NSAttributedString(
                    string: initials,
                    attributes: [.font: UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.white]
                )
                self.view?.updateAvatar(with: .initials(attributedInitials))
            } else {
                self.view?.updateAvatar(with: .image(UIImage(named: "avatar") ?? .init()))
            }
        }.store(in: &cancellables)
    }
    
    private func presentError(with error: ConversationsListInteractorError) {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        switch error {
            
        case .createChannelError:
            let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.createChannel()
            }
            router.showAlert(with:
                    .init(
                        title: "Could not create channel",
                        message: "Try again",
                        style: .alert,
                        actions: [tryAgainAction, cancelAction]
                    )
            )
            
        case .loadProfileError:
            break
        case .loadChannelsError:
            let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.loadChannels()
            }
            router.showAlert(with:
                    .init(
                        title: "Could not load channels",
                        message: "Try again",
                        style: .alert,
                        actions: [tryAgainAction, cancelAction]
                    )
            )
        case .deleteChannelError:
            break
        }
    }
    
    private func createChannel() {
        guard let name = addChannelText.value else { return }
        interactor.createChannel(name: name)
    }
    
    private func loadChannels() {
        interactor.loadChannels()
    }
}

// MARK: - ConversationsListViewOutput

extension ConversationsListPresenter: ConversationsListViewOutput {
    
    func numberOfRows(in section: Int) -> Int {
        interactor.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func viewModel(for indexPath: IndexPath) -> ConversationsListCell.ViewModel {
        let channel = interactor.fetchedResultsController.object(at: indexPath)
        return convertChannelToViewModel(with: channel, isLast: indexPath.row == numberOfRows(in: indexPath.section))
    }
    
    func reloadData() {
        loadChannels()
    }
    
    func addChannelTapped() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            self?.createChannel()
        }
        
        let textFieldAction: ((UITextField) -> Void) = { [weak self] textField in
            guard let self = self else { return }
            textField.textPublisher.assign(to: \.value, on: self.addChannelText).store(in: &self.cancellables)
        }
        router.addChannel(with: .init(title: "New Channel", textFieldAction: textFieldAction, actions: [cancelAction, createAction]))
    }
    
    func viewLoaded() {
        loadAvatar()
        loadChannels()
    }
}

extension ConversationsListPresenter: ConversationsListInteractorOutput {
    func receivedError(_ error: ConversationsListInteractorError) {
        presentError(with: error)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        view?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            view?.insertRow(at: newIndexPath)
        case .delete:
            guard let indexPath = indexPath else { return }
            view?.deleteRow(at: indexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            view?.reloadRow(at: indexPath)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            view?.moveRow(at: indexPath, to: newIndexPath)
        @unknown default:
            assertionFailure("Unhandled NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        view?.endUpdates()
    }
}
