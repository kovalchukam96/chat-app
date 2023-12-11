import UIKit

protocol ImageLoader: AnyObject {
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void)
}

class ImageLoaderImpl: ImageLoader {
    private let imageCache: ImageCache
    
    private let logger: Logger
    
    init(imageCache: ImageCache, logger: Logger) {
        self.imageCache = imageCache
        self.logger = logger
    }

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.getImage(forKey: url.absoluteString) {
            completion(cachedImage)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                self?.logger.error("Failed to download image: \(url)")
                completion(nil)
                return
            }
            self?.imageCache.setImage(image, forKey: url.absoluteString)

            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        loadImage(from: url, completion: completion)
    }
}
