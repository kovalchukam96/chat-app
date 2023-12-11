import UIKit
import Combine
import TFSChatTransport
import CoreData

protocol ConversationViewOutput: AnyObject {
    func viewLoaded()
    func returnBack()
    func updateMessage(with text: String?)
    func numberOfRows(in section: Int) -> Int
    func numberOfSections() -> Int
    func viewModel(for indexPath: IndexPath) -> ConversationCell.ViewModel

}

final class ConversationPresenter: NSObject {
    private weak var view: ConversationViewInput?
    private let router: ConversationRouterInput
    private let interactor: ConversationInteractorInput
    private let dateFormatter = MessengerDateFormatter()
    private let context: ConversationContext
    private let userStorage: UserStorage
    private let profileDataStore: ProfileDataStore
    
    private var cancellables = Set<AnyCancellable>()
    
    private var messageText: String?
    
    private var messages: [Message] = []
    
    private lazy var userName = profileDataStore.profile.value?.name
    
    private lazy var userID = getUserID()
    
    init(
        view: ConversationViewInput,
        router: ConversationRouterInput,
        interactor: ConversationInteractorInput,
        userStorage: UserStorage,
        profileDataStore: ProfileDataStore,
        context: ConversationContext
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.context = context
        self.userStorage = userStorage
        self.profileDataStore = profileDataStore
    }
    
    func createViewModel(from message: Message) -> ConversationCell.ViewModel {
        .init(
            name: message.userName,
            message: message.text,
            date: dateFormatter.string(from: message.date),
            isOutcoming: message.userID == userID
        )
    }
    
    func getUserID() -> String {
        let userID = userStorage.getValue(for: Constants.userIDKey)
        if  let userID = userID {
            return userID
        } else {
            let uid = UUID().uuidString
            userStorage.setValue(value: uid, for: Constants.userIDKey)
            return uid
        }
    }
    
    func observeProfile() {
        profileDataStore.profile.sink { [weak self] profile in
            self?.userName = profile?.name
        }.store(in: &cancellables)
    }
    
    func configureView() {

        let viewModel = ConversationView.ViewModel(
            avatar: .init(avatar: context.avatar, name: context.name, action: returnBack),
            sendAction: sendMessage
        )
        view?.configure(with: viewModel)
    }
    private func convertMessageToViewModel(with message: DBMessage, isOtcoming: Bool) -> ConversationCell.ViewModel {
        let name = message.userName ?? ""
        let text = message.text ?? ""
        let date: String
        if let sendTime = message.date {
            date = dateFormatter.string(from: sendTime)
        } else {
            date = ""
        }
        return ConversationCell.ViewModel(
            name: name,
            message: text,
            date: date,
            isOutcoming: isOtcoming)
    }
    
    private func presentError(with error: ConversationInteractorError) {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        switch error {
            
        case .loadMessagesError:
            let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.loadMessages()
            }
            router.showAlert(with: .init(title: "Could not load messages", message: "Try again", style: .alert, actions: [tryAgainAction, cancelAction]))
            
        case .sendMessageError:
            let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.sendMessage()
            }
            router.showAlert(with: .init(title: "Could not send message", message: "Try again", style: .alert, actions: [tryAgainAction, cancelAction]))
        }
    }
    
    private func loadMessages() {
        interactor.loadMessages()
    }
    
    private func sendMessage() {
        guard let messageText = messageText, !messageText.isEmpty else { return }
        interactor.sendMessage(
            text: messageText,
            channelId: context.channelID,
            userId: userID,
            userName: userName ?? "anonymous"
        )
        self.messageText = nil
    }
    
}

// MARK: - ConversationViewOutput

extension ConversationPresenter: ConversationViewOutput {
    func numberOfRows(in section: Int) -> Int {
        interactor.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections() -> Int {
        interactor.fetchedResultsController.sections?.count ?? 0
    }
    
    func viewModel(for indexPath: IndexPath) -> ConversationCell.ViewModel {
        let message = interactor.fetchedResultsController.object(at: indexPath)
        return convertMessageToViewModel(with: message, isOtcoming: message.userID == userID)
    }
    
    func updateMessage(with text: String?) {
        messageText = text
    }
    
    func returnBack() {
        router.returnBack()
    }
    
    func viewLoaded() {
        configureView()
        loadMessages()
    }
}

extension ConversationPresenter: ConversationInteractorOutput {
    func receivedError(_ error: ConversationInteractorError) {
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

extension ConversationPresenter {
    enum Constants {
        static let userIDKey = "userID"
    }
}
