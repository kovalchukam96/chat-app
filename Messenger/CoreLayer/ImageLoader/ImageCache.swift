import UIKit

protocol ImageCache: AnyObject {
    func getImage(forKey key: String) -> UIImage?
    func setImage(_ image: UIImage, forKey key: String)
}

class ImageCacheImpl: ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    
    private let queue = DispatchQueue(
        label: "com.messenger.imageCache.queue",
        qos: .userInitiated,
        attributes: .concurrent
    )

    func getImage(forKey key: String) -> UIImage? {
        queue.sync {
            return cache.object(forKey: NSString(string: key))
        }
    }

    func setImage(_ image: UIImage, forKey key: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.setObject(image, forKey: NSString(string: key))
        }
    }
}
