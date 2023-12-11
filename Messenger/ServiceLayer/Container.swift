import UIKit
import TFSChatTransport

protocol Container {
    var dataStore: DataStore { get }
    var profileDataStore: ProfileDataStore { get }
    var conversationsListDataStore: ConversationsListDataStore { get }
    var conversationDataStore: ConversationDataStore { get }
    var themeManager: ThemeManager { get }
    var chatService: ChatService { get }
    var userStorage: UserStorage { get }
    var coreDataService: CoreDataService { get }
    var logger: Logger { get }
    var imageLoader: ImageLoader { get }
    var networkClient: NetworkClient { get }
    var chatManager: ChatManagerImpl { get }
}

final class ContainerImpl: Container {
    lazy var coreDataService: CoreDataService = CoreDataServiceImpl(logger: logger, modelName: "Chat")
    lazy var userStorage: UserStorage = UserStorageImpl()
    lazy var dataStore: DataStore = DataStoreImpl()
    lazy var profileDataStore: ProfileDataStore = ProfileDataStoreImpl(dataStore: dataStore)
    lazy var conversationsListDataStore: ConversationsListDataStore = ConversationsListDataStoreImpl(
        coreDataService: coreDataService
    )
    lazy var conversationDataStore: ConversationDataStore = ConversationDataStoreImpl(
        coreDataService: coreDataService,
        logger: logger
    )
    lazy var themeManager: ThemeManager = .init()
    lazy var chatService: ChatService = .init(host: "167.235.86.234", port: 8080)
    lazy var logger: Logger = .init()
    lazy var imageLoader: ImageLoader = ImageLoaderImpl(imageCache: ImageCacheImpl(), logger: logger)
    lazy var networkClient: NetworkClient = NetworkClientImpl()
    lazy var chatManager = ChatManagerImpl(
            sseService: .init(host: "167.235.86.234", port: 8080),
            chatService: chatService,
            conversationsListDataStore: conversationsListDataStore,
            conversationDataStore: conversationDataStore
        )
}
