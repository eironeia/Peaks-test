//
//  AppDelegate.swift
//  PeaksTest
//
//  Created by Alex Cuello on 11/07/2019.
//  Copyright © 2019 eironeia. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let window = UIWindow(frame: UIScreen.main.bounds)
        setup(window: window)

        return true
    }

    func setup(window: UIWindow) {
        self.window = window
        window.rootViewController = SquaresIntersectionViewController()
        window.makeKeyAndVisible()
    }
}

