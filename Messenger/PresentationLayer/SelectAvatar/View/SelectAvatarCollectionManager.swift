import UIKit

protocol SelectAvatarCollectionManagerDelegate: AnyObject {
    func didScrollToBottom()
}

final class SelectAvatarCollectionManager:
    NSObject,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {
    
    var viewModels: [URL]?
    
    weak var collectionView: UICollectionView?
    
    weak var delegate: SelectAvatarCollectionManagerDelegate?
    
    var presenter: SelectAvatarViewOutput?
    
    var isLoadingMoreData: Bool = false
    
    private let imageLoader: ImageLoader
    
    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return viewModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SelectAvatarCell", for: indexPath
            ) as? SelectAvatarCell,
            let url = viewModels?[indexPath.row]
        else  {
            return UICollectionViewCell()
        }
        cell.tag = url.hashValue
        
        imageLoader.loadImage(from: url) { [weak cell] image in
            guard cell?.tag == url.hashValue else { return }
            cell?.configure(with: image)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = viewModels?[indexPath.row] else { return }
        imageLoader.loadImage(from: url) { [weak self] image in
            guard let image = image else { return }
            self?.presenter?.didSelectAvatar(with: image)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if indexPath.row == (viewModels?.count ?? 0) - 1 {
            self.delegate?.didScrollToBottom()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 1
        return .init(width: width, height: width)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 1
    }
}
