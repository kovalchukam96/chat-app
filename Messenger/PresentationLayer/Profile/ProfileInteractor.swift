import Combine
import UIKit

protocol ProfileInteractorInput: ProfileDataStore { }

final class ProfileInteractor {
    
    private let dataStore: ProfileDataStore
    
    init(dataStore: ProfileDataStore) {
        self.dataStore = dataStore
    }
}

// MARK: - ProfileInteractorInput

extension ProfileInteractor: ProfileInteractorInput {
    var error: CurrentValueSubject<ProfileDataStoreError?, Never> {
        dataStore.error
    }
    
    var profile: CurrentValueSubject<Profile?, Never> {
        dataStore.profile
    }
    
    func loadData() {
        dataStore.loadData()
    }
    
    func saveData(model: Profile) {
        dataStore.saveData(model: model)
    }
    
    func cancelSaving() {
        dataStore.cancelSaving()
    }
}
