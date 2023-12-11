import Combine
import UIKit

protocol ProfileViewOutput: AnyObject {
    func viewLoaded()
    func closeButtonTapped()
}

final class ProfilePresenter: NSObject {
    private weak var view: ProfileViewInput?
    private let router: ProfileRouterInput
    private let interactor: ProfileInteractorInput
    private var currentProfile: Profile?
    private var editProfile: Profile?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var saveSubscription: Cancellable?
    
    init(
        view: ProfileViewInput,
        router: ProfileRouterInput,
        interactor: ProfileInteractorInput
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    private func loadData() {
        interactor.loadData()
        interactor.profile.sink { [weak self] profile in
            self?.presentData(with: profile)
        }.store(in: &cancellables)
        interactor.error.sink { [weak self] error in
            guard let error = error else { return }
            self?.presentError(with: error)
        }.store(in: &cancellables)
    }
    
    private func presentError(with error: ProfileDataStoreError) {
        switch error {
        case .loadDataError:
            break
        case .saveDataError:
            let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.presentEdit(with: nil)
            }
            let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.saveData()
            }
            router.showAlert(
                with:
                        .init(
                            title: "Could not save profile",
                            message: "Try again",
                            style: .alert,
                            actions: [okAction, tryAgainAction]
                        )
            )
        }
    }
    
    private func presentData(with model: Profile?) {
        currentProfile = model
        let name = model?.name ?? "No name"
        let info = model?.bio ?? "No bio specified"
        let avatar: AvatarImageView.ViewModel
        if let image = model?.avatar {
            avatar = .image(image.image)
        } else if let name = model?.name {
            let initials = name.createInitials()
            let attributedInitials = NSAttributedString(
                string: initials,
                attributes: [.font: UIFont.boldSystemFont(ofSize: 48), .foregroundColor: UIColor.white]
            )
            avatar = .initials(attributedInitials)
        } else {
            avatar = .image(UIImage(named: "avatar") ?? .init())
        }
        
        let viewModel = ProfileView.ViewModel.initial(
            .init(
                name: name,
                info: info,
                avatar: avatar,
                addPhotoAction: { [weak self] in self?.addPhotoTappedFromInitialState() },
                rightBarButtonAction: { [weak self] in self?.presentEdit(with: model) }
            )
        )
        view?.displayData(with: viewModel)
    }
    
    private func presentEdit(with model: Profile?) {
        let nameSubject = CurrentValueSubject<String?, Never>(model?.name)
        nameSubject.sink { [weak self] name in
            self?.updateName(with: name)
        }.store(in: &cancellables)
        let bioSubject = CurrentValueSubject<String?, Never>(model?.bio)
        bioSubject.sink { [weak self] bio in
            self?.updateBio(with: bio)
        }.store(in: &cancellables)
        
        let viewModel = ProfileView.ViewModel.edit(
            .init(
                name: .init(labelName: "Name", text: nameSubject, placeholder: "Type your name"),
                info: .init(labelName: "Bio", text: bioSubject, placeholder: "Describe yourself"),
                addPhotoAction: { [weak self] in self?.addPhotoTapped() },
                leftBarButtonAction: { [weak self] in self?.presentCancel() },
                rightBarButtonAction: { [weak self] in self?.saveData() }
            )
        )
        view?.displayData(with: viewModel)
    }
    
    private func presentSaving() {
        let viewModel = ProfileView.ViewModel.saving(
            .init(
                leftBarButtonAction: { [weak self] in
                    guard let self = self else { return }
                    self.presentCancel()
                }
            )
        )
        view?.displayData(with: viewModel)
    }
    
    private func addPhotoTappedFromInitialState() {
        presentEdit(with: currentProfile)
        addPhotoTapped()
    }
    
    private func saveData() {
        guard let editProfile = editProfile else {
            presentSuccessAlert()
            return
        }
        presentSaving()
        interactor.saveData(model: editProfile)
        interactor.profile.sink { [weak self] profile in
            guard let self = self else {
                return
            }
            if let avatar = profile?.avatar {
                self.currentProfile?.avatar = avatar
            }
            if let name = profile?.name {
                self.currentProfile?.name = name
            }
            if let bio = profile?.bio {
                self.currentProfile?.bio = bio
            }
            self.presentSuccessAlert()
        }.store(in: &cancellables)
    }
    
    private func addPhotoTapped() {
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.router.showCamera(delegate: self)
        }
        
        let libraryAction = UIAlertAction(title: "Choose From Library", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.router.showLibrary(delegate: self)
        }
        
        let downloadAction = UIAlertAction(title: "Download", style: .default) { [weak self] _ in
            self?.router.showDownload { [weak self] image in
                self?.updateAvatar(with: image)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        router.showAlert(
            with: .init(
                title: "Select photo",
                message: nil,
                style: .actionSheet,
                actions: [cameraAction, libraryAction, cancelAction, downloadAction]
            )
        )
    }
    
    private func presentSuccessAlert() {
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presentData(with: self.currentProfile)
        }
        router.showAlert(with: .init(title: "Success", message: "You are breathtaking", style: .alert, actions: [okAction]))
        view?.updateRightBarButton()
    }
    
    private func presentCancel() {
        editProfile = nil
        interactor.cancelSaving()
        saveSubscription?.cancel()
        presentData(with: currentProfile)
    }
    
    private func updateName(with text: String?) {
        if editProfile == nil {
            editProfile = Profile(avatar: nil, name: text, bio: nil)
        } else {
            editProfile?.name = text
        }
    }
    
    private func updateBio(with text: String?) {
        if editProfile == nil {
            editProfile = Profile(avatar: nil, name: nil, bio: text)
        } else {
            editProfile?.bio = text
        }
    }
    
    private func updateAvatar(with image: UIImage) {
        if editProfile == nil {
            editProfile = Profile(avatar: .init(image: image), name: nil, bio: nil)
        } else {
            editProfile?.avatar = .init(image: image)
        }
        view?.updateAvatar(image: image)
    }
    
}

// MARK: - ProfileViewOutput

extension ProfilePresenter: ProfileViewOutput {
    func closeButtonTapped() {
        router.close()
    }
    
    func viewLoaded() {
        loadData()
    }
}

extension ProfilePresenter: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
           updateAvatar(with: image)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
