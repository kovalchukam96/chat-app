import UIKit

protocol SettingsViewOutput: AnyObject {
    func viewLoaded()
    func updateUserInterfaceStyle(with style: UIUserInterfaceStyle)
}

final class SettingsPresenter {
//    Retain cycle может возникнуть в случае если view объявить без weak
    private weak var view: SettingsViewInput?
    
    private let themeManager = ThemeManager()

    init(
        view: SettingsViewInput
    ) {
        self.view = view
    }
    
    func presentData() {
// Также retain cycle может возникнуть если в замыканиях не будет weak self
        let dayMode = SettingsThemeSwitchView.ViewModel(interfaceStyle: .light) { [weak self] in
            self?.updateUserInterfaceStyle(with: .light)
        }
        
        let nightMode = SettingsThemeSwitchView.ViewModel(interfaceStyle: .dark) { [weak self] in
            self?.updateUserInterfaceStyle(with: .dark)
        }
        
        let viewModel = SettingsView.ViewModel(dayMode: dayMode, nightMode: nightMode)
        view?.displayData(with: viewModel)
        view?.updateState(with: themeManager.getCurrentTheme())
    }
    
}

extension SettingsPresenter: SettingsViewOutput {
    func updateUserInterfaceStyle(with style: UIUserInterfaceStyle) {
        view?.updateState(with: style)
        themeManager.changeTheme(for: style)
    }
    
    func viewLoaded() {
        presentData()
    }
}
