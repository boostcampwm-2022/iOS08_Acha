//
//  AppDelegate.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/11.
//

import UIKit
import FirebaseCore
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        DependenciesDefinition().inject()
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .pointLight
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().standardAppearance = appearance
        
        if #available(iOS 15, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        guard let roomID = UserDefaults.standard.value(forKey: "roomID") as? String else {return}
        UserDefaults.standard.removeObject(forKey: "roomID")
        print(roomID)
        let service = DefaultRealtimeDatabaseNetworkService()
        service.terminate(type: .room(id: roomID))
        sleep(5)
    }
}
