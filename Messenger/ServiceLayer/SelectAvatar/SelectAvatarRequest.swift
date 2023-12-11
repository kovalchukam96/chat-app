import Foundation

struct SelectAvatarRequest: DataRequest {
    typealias Response = SelectAvatarDTO
    
    var url: String {
        let baseURL: String = "https://pixabay.com/"
        let path: String = "api/"
        return baseURL + path
    }
    
    var queryItems: [String: String] {
        [
            "key": key,
            "page": "\(page)",
            "pageSize": "\(pageSize)"

        ]
    }
    
    var method: HTTPMethod {
        .get
    }
    
    private let key: String
    private let page: Int
    private let pageSize: Int
    
    init?(page: Int, pageSize: Int) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "APIKey") as? String else { return nil }
        self.key = apiKey
        self.page = page
        self.pageSize = pageSize
    }
}
