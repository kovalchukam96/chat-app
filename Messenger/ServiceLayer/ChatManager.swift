import Combine
import Foundation
import TFSChatTransport

final class ChatManagerImpl {
    private let sseService: SSEService
    private let chatService: ChatService
    private let conversationsListDataStore: ConversationsListDataStore
    private let conversationDataStore: ConversationDataStore
    private var cancellables = Set<AnyCancellable>()
    
    init(
        sseService: SSEService,
        chatService: ChatService,
        conversationsListDataStore: ConversationsListDataStore,
        conversationDataStore: ConversationDataStore
    ) {
        self.sseService = sseService
        self.chatService = chatService
        self.conversationsListDataStore = conversationsListDataStore
        self.conversationDataStore = conversationDataStore
        subscribeOnEvents()
    }
    
    func subscribeOnEvents() {
        sseService.subscribeOnEvents().sink { _ in
        } receiveValue: { [weak self] event in
            switch event.eventType {
            case .add:
                self?.loadChannel()
            case .update:
                self?.loadMessages(id: event.resourceID)
            case .delete:
                self?.loadChannel()
            }
        }.store(in: &cancellables)
    }
    
    func loadChannel() {
        chatService.loadChannels().receive(on: DispatchQueue.main).sink { _ in
        } receiveValue: { [weak self] channels in
            self?.conversationsListDataStore.saveOrUpdate(channels: channels)
        }.store(in: &cancellables)
    }
    
    func loadMessages(id: String) {
        chatService.loadMessages(channelId: id).receive(on: DispatchQueue.main).sink { _ in
        } receiveValue: { [weak self] messages in
            guard let self = self else { return }
            self.conversationDataStore.saveMessages(channelID: id, messages: messages)
        }.store(in: &cancellables)
    }
}
