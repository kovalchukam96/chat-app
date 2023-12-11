import Combine
import UIKit
import TFSChatTransport
import CoreData

enum ConversationsListInteractorError: Error {
    case createChannelError
    case loadProfileError
    case loadChannelsError
    case deleteChannelError
}

protocol ConversationsListInteractorOutput: NSFetchedResultsControllerDelegate {
    func receivedError(_ error: ConversationsListInteractorError)
}

protocol ConversationsListInteractorInput {
    var profile: CurrentValueSubject<Profile?, Never> { get }
    var fetchedResultsController: NSFetchedResultsController<DBChannel> { get }
    func loadProfile()
    func createChannel(name: String)
    func loadChannels()
    func deleteChannel(id: String)
}

final class ConversationsListInteractor: NSObject {
    
    weak var output: ConversationsListInteractorOutput?
    
    private let profileDataStore: ProfileDataStore
    private let chatService: ChatService
    private let coreDataService: CoreDataService
    
    private let conversationsListDataStore: ConversationsListDataStore
    
    private var cancellables = Set<AnyCancellable>()
    
    private(set) lazy var fetchedResultsController: NSFetchedResultsController<DBChannel> = {
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: conversationsListDataStore.channelsRequest(),
            managedObjectContext: coreDataService.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    init(
        profileDataStore: ProfileDataStore,
        chatService: ChatService,
        coreDataService: CoreDataService,
        conversationsListDataStore: ConversationsListDataStore
    ) {
        self.profileDataStore = profileDataStore
        self.chatService = chatService
        self.coreDataService = coreDataService
        self.conversationsListDataStore = conversationsListDataStore
    }
}

// MARK: - ConversationsListInteractorInput

extension ConversationsListInteractor: ConversationsListInteractorInput {
    
    var profile: CurrentValueSubject<Profile?, Never> {
        profileDataStore.profile
    }
    
    func loadChannels() {
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            print(error.localizedDescription)
        }
        chatService.loadChannels().receive(on: DispatchQueue.main).sink { [weak self] result in
            switch result {
                
            case .finished:
                break
            case .failure:
                self?.output?.receivedError(.loadChannelsError)
            }
        } receiveValue: { [weak self] channels in
            self?.conversationsListDataStore.saveOrUpdate(channels: channels)
        }.store(in: &cancellables)
    }
    
    func createChannel(name: String) {
        chatService.createChannel(name: name).receive(on: DispatchQueue.main).sink { [weak self] result in
            switch result {
                
            case .finished:
                break
            case .failure:
                self?.output?.receivedError(.createChannelError)
            }
        } receiveValue: { [weak self] channel in
            self?.conversationsListDataStore.saveOrUpdate(newChannel: channel)
        }.store(in: &cancellables)

    }
    
    func deleteChannel(id: String) {
        chatService.deleteChannel(id: id).receive(on: DispatchQueue.main).sink { [weak self] result in
            switch result {
                
            case .finished:
                break
            case .failure(let error):
                print(error)
                self?.output?.receivedError(.deleteChannelError)
            }
        } receiveValue: { [weak self] _ in
            self?.conversationsListDataStore.deleteChannel(id: id)
        }.store(in: &cancellables)

    }
    
    func loadProfile() {
        profileDataStore.loadData()
    }
}

extension ConversationsListInteractor: NSFetchedResultsControllerDelegate {
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
