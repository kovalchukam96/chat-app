import UIKit
import Combine
import TFSChatTransport
import CoreData

enum ConversationInteractorError: Error {
    case loadMessagesError
    case sendMessageError
}

protocol ConversationInteractorOutput: NSFetchedResultsControllerDelegate {
    func receivedError(_ error: ConversationInteractorError)
}

protocol ConversationInteractorInput {
    var fetchedResultsController: NSFetchedResultsController<DBMessage> { get }
    func loadMessages()
    func sendMessage(text: String, channelId: String, userId: String, userName: String)
}

final class ConversationInteractor: NSObject {
    
    weak var output: ConversationInteractorOutput?
    
    private let chatService: ChatService
    private let coreDataService: CoreDataService
    
    private let conversationDataStore: ConversationDataStore
    
    private let channelID: String
    
    private var cancellables = Set<AnyCancellable>()
    
    private(set) lazy var fetchedResultsController: NSFetchedResultsController<DBMessage> = {
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: conversationDataStore.messagesRequest(for: channelID),
            managedObjectContext: coreDataService.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    init(
        chatService: ChatService,
        coreDataService: CoreDataService,
        conversationDataStore: ConversationDataStore,
        channelID: String
    ) {
        self.chatService = chatService
        self.coreDataService = coreDataService
        self.conversationDataStore = conversationDataStore
        self.channelID = channelID
    }
}

// MARK: - ConversationInteractorInput

extension ConversationInteractor: ConversationInteractorInput {
    func loadMessages() {
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            print(error.localizedDescription)
        }
        chatService.loadMessages(channelId: channelID).receive(on: DispatchQueue.main).sink { [weak self] result in
            switch result {
                
            case .finished:
                break
            case .failure:
                self?.output?.receivedError(.loadMessagesError)
            }
        } receiveValue: { [weak self] messages in
            guard let self = self else { return }
            self.conversationDataStore.saveMessages(channelID: self.channelID, messages: messages)
        }.store(in: &cancellables)
    }
    
    func sendMessage(text: String, channelId: String, userId: String, userName: String) {
        chatService.sendMessage(
            text: text,
            channelId: channelId,
            userId: userId,
            userName: userName
        ).receive(on: DispatchQueue.main).sink { [weak self] result in
            switch result {
                
            case .finished:
                break
            case .failure:
                self?.output?.receivedError(.sendMessageError)
            }
        } receiveValue: { [weak self] message in
            self?.conversationDataStore.saveMessage(channelID: channelId, message: message)
        }.store(in: &cancellables)
    }
}

extension ConversationInteractor: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        output?.controller?(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        output?.controllerWillChangeContent?(controller)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        output?.controllerDidChangeContent?(controller)
    }
}
