//
//  SceneDelegate.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/12.
//

import UIKit
import IyashiDogFeature
import MVP

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        HTTPClientURLSession(session: URLSession.init(configuration: .ephemeral))
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }

    private func configureWindow() {
        let navigation = UINavigationController(
            rootViewController:
                DogUIComposer.dogComposed(
                    with: makeRemoteDogLoader(),
                    imageLoader: makeRemoteDogImageLoader()))
        window?.rootViewController = navigation
        
        window?.makeKeyAndVisible()
    }
    
    private func makeRemoteDogLoader() -> DogLoader {
        let remoteURL = URL(string: "https://dog.ceo/api/breed/corgi/images")!
        
        return RemoteDogLoader(client: httpClient, url: remoteURL)
    }

    private func makeRemoteDogImageLoader() -> DogImageDataLoader {
        return RemoteDogImageDataLoader(client: httpClient)
    }
    
}

