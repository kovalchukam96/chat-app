import UIKit

struct Profile: Codable {
    var avatar: ImageWrapper?
    var name: String?
    var bio: String?
}

extension Profile: Equatable {}

struct ImageWrapper: Codable {
  let image: UIImage

  enum CodingKeys: String, CodingKey {
    case image
  }

  init(image: UIImage) {
    self.image = image
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let data = try container.decode(Data.self, forKey: CodingKeys.image)
    guard let image = UIImage(data: data) else {
        throw CodingError.decoding
    }
    self.image = image
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    guard let data = image.jpegData(compressionQuality: 1) else {
          throw CodingError.encoding
    }
    try container.encode(data, forKey: CodingKeys.image)
  }
}

extension ImageWrapper: Equatable {}

enum CodingError: Error {
    case encoding
    case decoding
}
