import Foundation

struct SelectAvatarModel: Codable {
    struct Image: Codable {
        let previewURL: String
    }
    let total: Int
    var hits: [Image]
    
    init(from dto: SelectAvatarDTO) {
        self.hits = dto.hits.map { SelectAvatarModel.Image(previewURL: $0.previewURL) }
        self.total = dto.total
        
    }
}
