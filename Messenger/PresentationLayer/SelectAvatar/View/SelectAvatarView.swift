import UIKit

final class SelectAvatarView: UIView {
    
    var activityIndicator = UIActivityIndicatorView()
    
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = ColorPalette.Background.primary
        collectionView.register(SelectAvatarCell.self, forCellWithReuseIdentifier: "SelectAvatarCell")
        return collectionView
    }()
    
    init(collectionViewManager: UICollectionViewDataSource & UICollectionViewDelegate) {
        super.init(frame: .zero)
        collectionView.delegate = collectionViewManager
        collectionView.dataSource = collectionViewManager
        applyLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyLayout() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.widthAnchor.constraint(equalToConstant: 20),
            activityIndicator.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupView() {
        backgroundColor = ColorPalette.Background.primary
        activityIndicator.startAnimating()
    }
    
}
