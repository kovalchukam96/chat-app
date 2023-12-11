import UIKit

extension ProfileView {
    enum ViewModel {
        case initial(InitialModel)
        case edit(EditModel)
        case saving(SavingModel)
        
        struct InitialModel {
            let name: String
            let info: String
            let avatar: AvatarImageView.ViewModel
            let addPhotoAction: () -> Void
            let rightBarButtonAction: () -> Void
        }
        struct EditModel {
            let name: ProfileDataEditView.ViewModel
            let info: ProfileDataEditView.ViewModel
            let addPhotoAction: () -> Void
            let leftBarButtonAction: () -> Void
            let rightBarButtonAction: () -> Void
        }
        struct SavingModel {
            let leftBarButtonAction: () -> Void
        }
    }
}
