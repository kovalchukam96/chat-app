import UIKit

final class SettingsFactory {

    func build() -> SettingsViewController {
        let vc = SettingsViewController()

        let presenter = SettingsPresenter(
            view: vc
        )

        vc.presenter = presenter

        return vc
    }
}
