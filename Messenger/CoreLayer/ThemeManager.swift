import UIKit

final class ThemeManager {
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        let theme = getCurrentTheme()
        changeTheme(for: theme)
    }
    
    func changeTheme(for style: UIUserInterfaceStyle) {
        userDefaults.set(style.string, forKey: Constants.themeKey)
        UIApplication.shared.windows
                    .forEach { $0.overrideUserInterfaceStyle = style }
    }
    
    func getCurrentTheme() -> UIUserInterfaceStyle {
        let theme = userDefaults.string(forKey: Constants.themeKey)
        switch theme {
        case Constants.light: return .light
        case Constants.dark: return .dark
        default: return .light
        }
    }
}

private enum Constants {
    static let themeKey = "theme_key"
    static let dark = "dark"
    static let light = "light"
}

private extension UIUserInterfaceStyle {
    var string: String {
        switch self {
        case .dark:
            return Constants.dark
        default:
            return Constants.light
        }
    }
}
