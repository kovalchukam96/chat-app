import Combine
import UIKit

enum ProfileDataStoreError: Error {
    case loadDataError
    case saveDataError
}

protocol ProfileDataStore: AnyObject {
    var profile: CurrentValueSubject<Profile?, Never> { get }
    var error: CurrentValueSubject<ProfileDataStoreError?, Never> { get }
    func loadData()
    func saveData(model: Profile)
    func cancelSaving()
}

final class ProfileDataStoreImpl: ProfileDataStore {
    
    var profile = CurrentValueSubject<Profile?, Never>(nil)
    var error = CurrentValueSubject<ProfileDataStoreError?, Never>(nil)
    
    private let dataStore: DataStore
    
    private let encoder: JSONEncoderType
    private let decoder: JSONDecoderType
    
    private var cancel = CancelWrapper()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        dataStore: DataStore,
        encoder: JSONEncoderType = JSONEncoder(),
        decoder: JSONDecoderType = JSONDecoder()
    ) {
        self.dataStore = dataStore
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func loadData() {
         dataStore
            .get(path: Constants.profilePath)
            .map { [weak self] data -> Profile? in
                guard let self = self, let data = data else {
                    return nil
                }
                return try? self.decoder.decode(Profile.self, from: data)
            }
            .mapError { error in
                self.error.value = ProfileDataStoreError.loadDataError
                return error
            }
            .replaceError(with: nil)
            .assign(to: \.profile.value, on: self)
            .store(in: &cancellables)
    }
    
    func saveData(model: Profile) {
        guard let data = try? encoder.encode(model) else { return }
        cancel = CancelWrapper()
        dataStore
            .save(data: data, path: Constants.profilePath, cancel: cancel)
            .map { [weak self] in
                guard let self = self else { return nil }
                let oldProfile = self.profile.value
                let avatar = model.avatar ?? oldProfile?.avatar
                let name = model.name ?? oldProfile?.name
                let bio = model.bio ?? oldProfile?.bio
                return .init(avatar: avatar, name: name, bio: bio)
            }
            .mapError { error in
                self.error.value = ProfileDataStoreError.saveDataError
                return error
            }
            .replaceError(with: nil)
            .assign(to: \.profile.value, on: self)
            .store(in: &cancellables)
    }
    
    func cancelSaving() {
        cancel.isCancelled = true
    }
}

private extension ProfileDataStoreImpl {
    enum Constants {
        static let profilePath = "ProfilePath"
    }
}
