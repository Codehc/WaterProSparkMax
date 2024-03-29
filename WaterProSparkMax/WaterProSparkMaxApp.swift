//
//  WaterProSparkMaxApp.swift
//  WaterProSparkMax
//
//  Created by Reza Bagheri on 4/27/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

@main
struct WaterProSparkMaxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var plants = ConfigList()
    
    var body: some Scene {
        WindowGroup {
            PlantSelectionView()
                .environmentObject(plants)
        }
    }
}
