//
//  SceneDelegate.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let viewController = MainViewController()
        let baseURL = "https://some_url_here"
        let networkClientFactory = HttpClientFactory(baseURL: baseURL)
        viewController.viewModel = ViewModel(networkClientFactory: networkClientFactory)
        window = UIWindow(windowScene: scene)
        window?.rootViewController = UINavigationController(rootViewController: viewController)
        window?.makeKeyAndVisible()
    }
}
