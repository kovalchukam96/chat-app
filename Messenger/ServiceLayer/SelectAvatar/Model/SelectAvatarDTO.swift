import Foundation

struct SelectAvatarDTO: Codable {
    struct Image: Codable {
        let previewURL: String
    }
    let total: Int
    let hits: [Image]
    
}
