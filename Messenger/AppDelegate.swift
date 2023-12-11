//
//  AppDelegate.swift
//  Messenger
//
//  Created by Артем Ковальчук on 18.02.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let container: Container = ContainerImpl()
    
    private let tabBarDelegate = TabBarControllerDelegate()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        printDescription(fromState: .notRunning, toState: .inactive, method: #function)
        let window = EmitterWindow(frame: UIScreen.main.bounds)
        let tabBarController = UITabBarController()
        
        tabBarController.delegate = tabBarDelegate
        
        let channelsVC = ConversationsListFactory(container: container).build()
        let channelsNC = UINavigationController(rootViewController: channelsVC)
        let settingsVC = SettingsFactory().build()
        let settingsNC = UINavigationController(rootViewController: settingsVC)
        let profileVC = ProfileFactory(container: container).build()
        let profileNC = UINavigationController(rootViewController: profileVC)
        
        tabBarController.viewControllers = [channelsNC, settingsNC, profileNC]
        tabBarController.tabBar.backgroundColor = ColorPalette.Background.primary
        
        channelsNC.tabBarItem = UITabBarItem(title: "Channels", image: UIImage(named: "channelsBTN"), tag: 0)
        settingsNC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settingsBTN"), tag: 1)
        profileNC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileBTN"), tag: 2)
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
        _ = container.chatManager
        _ = ThemeManager()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        printDescription(fromState: .active, toState: .inactive, method: #function)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        printDescription(fromState: .inactive, toState: .active, method: #function)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        printDescription(fromState: .inactive, toState: .background, method: #function)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        printDescription(fromState: .background, toState: .inactive, method: #function)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        printDescription(fromState: .inactive, toState: .notRunning, method: #function)
    }
    
    private func printDescription(fromState: AppState, toState: AppState, method: String) {
        printDebug("Application moved from \(fromState.rawValue) to \(toState.rawValue): \(method)")
    }
    private enum AppState: String {
        case notRunning = "Not running"
        case inactive = "Inactive"
        case active = "Active"
        case background = "Background"
    }
}
