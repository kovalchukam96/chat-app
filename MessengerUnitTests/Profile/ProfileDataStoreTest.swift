import XCTest
import Combine
@testable import Messenger

final class ProfileDataStoreTest: XCTestCase {
    
    var dataStoreMock: DataStoreMock!
    var encoderMock: JSONEncoderMock!
    var decoderMock: JSONDecoderMock!
    var profileDataStore: ProfileDataStoreImpl!
    
    override func setUp() {
        super.setUp()
        dataStoreMock = .init()
        encoderMock = .init()
        decoderMock = .init()
        profileDataStore = .init(
            dataStore: dataStoreMock,
            encoder: encoderMock,
            decoder: decoderMock
        )
    }
    
    func testLoadDataSucces() {
        
        // Given
        dataStoreMock.stubbedGetResult = Just(TestData.data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        decoderMock.stubbedDecodeResult = TestData.profile
        
        // When
        profileDataStore.loadData()
        
        // Then
        XCTAssertEqual(dataStoreMock.invokedGetCount, 1)
        XCTAssertEqual(dataStoreMock.invokedGetParameters?.path, TestData.profilePath)
        XCTAssertEqual(profileDataStore.profile.value, TestData.profile)
        XCTAssertNil(profileDataStore.error.value)
        XCTAssertEqual(decoderMock.invokedDecodeCount, 1)
        XCTAssertEqual(decoderMock.invokedDecodeParameters?.data, TestData.data)
        
    }
    
    func testLoadDataError() {
        
        // Given
        dataStoreMock.stubbedGetResult = Fail(error: TestData.loadDataError).eraseToAnyPublisher()
        
        // When
        profileDataStore.loadData()
        
        // Then
        XCTAssertEqual(dataStoreMock.invokedGetCount, 1)
        XCTAssertEqual(dataStoreMock.invokedGetParameters?.path, TestData.profilePath)
        XCTAssertNil(profileDataStore.profile.value)
        XCTAssertEqual(profileDataStore.error.value, TestData.loadDataError)
    }
    
    func testSaveDataSucces() {
        
        // Given
        dataStoreMock.stubbedSaveResult = Just(())
         .setFailureType(to: Error.self)
         .eraseToAnyPublisher()
        encoderMock.stubbedEncodeResult = TestData.data
        
        // When
        profileDataStore.saveData(model: TestData.profile)
        
        // Then
        XCTAssertEqual(dataStoreMock.invokedSaveCount, 1)
        XCTAssertEqual(dataStoreMock.invokedSaveParameters?.path, TestData.profilePath)
        XCTAssertEqual(dataStoreMock.invokedSaveParameters?.data, TestData.data)
        XCTAssertEqual(profileDataStore.profile.value, TestData.profile)
        XCTAssertNil(profileDataStore.error.value)
        XCTAssertEqual(encoderMock.invokedEncodeCount, 1)
        XCTAssertEqual(encoderMock.invokedEncodeParameters?.value as? Profile, TestData.profile)
        
    }
    
    func testSaveDataSuccesWithOldModel() {
        
        // Given
        dataStoreMock.stubbedSaveResult = Just(())
         .setFailureType(to: Error.self)
         .eraseToAnyPublisher()
        profileDataStore.profile.value = TestData.profile
        encoderMock.stubbedEncodeResult = TestData.data
        
        // When
        profileDataStore.saveData(model: TestData.emptyProfile)
        
        // Then
        XCTAssertEqual(dataStoreMock.invokedSaveCount, 1)
        XCTAssertEqual(dataStoreMock.invokedSaveParameters?.path, TestData.profilePath)
        XCTAssertEqual(dataStoreMock.invokedSaveParameters?.data, TestData.data)
        XCTAssertEqual(profileDataStore.profile.value, TestData.profile)
        XCTAssertNil(profileDataStore.error.value)
        XCTAssertEqual(encoderMock.invokedEncodeCount, 1)
        XCTAssertEqual(encoderMock.invokedEncodeParameters?.value as? Profile, TestData.emptyProfile)
        
    }
    
    func testSaveDataError() {
        // Given
        dataStoreMock.stubbedSaveResult = Fail(error: TestData.saveDataError).eraseToAnyPublisher()
        encoderMock.stubbedEncodeResult = TestData.data
        
        // When
        profileDataStore.saveData(model: TestData.profile)
        
        // Then
        XCTAssertEqual(dataStoreMock.invokedSaveCount, 1)
        XCTAssertEqual(dataStoreMock.invokedSaveParameters?.path, TestData.profilePath)
        XCTAssertEqual(dataStoreMock.invokedSaveParameters?.data, TestData.data)
        XCTAssertNil(profileDataStore.profile.value)
        XCTAssertEqual(profileDataStore.error.value, TestData.saveDataError)
    }
    
}

extension ProfileDataStoreTest {
    enum TestData {
        static let profilePath = "ProfilePath"
        static let data = try? encoder.encode(profile)
        static let profile = Profile(
            avatar: .init(image: UIImage(systemName: "gear") ?? .init()),
            name: "Test",
            bio: "Test"
        )
        static let encoder = JSONEncoder()
        static let loadDataError = ProfileDataStoreError.loadDataError
        static let saveDataError = ProfileDataStoreError.saveDataError
        static let emptyProfile = Profile(avatar: nil, name: nil, bio: nil)
    }
}
