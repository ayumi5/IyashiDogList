//
//  DogUIComposer.swift
//  MVC
//
//  Created by 宇高あゆみ on 2022/06/04.
//

import Foundation
import IyashiDogFeature
import UIKit

public final class DogUIComposer {
    private init() {}
    
    static public func dogComposed(with loader: DogLoader, imageLoader: DogImageDataLoader) -> DogViewController {
        
        let bundle = Bundle(for: DogViewController.self)
        let storyboard = UIStoryboard(name: "Dog", bundle: bundle)
        let dogVC = storyboard.instantiateInitialViewController() as! DogViewController
        let dogRefreshVC = dogVC.dogRefreshViewController
        dogRefreshVC?.dogLoader = loader
        
        dogRefreshVC?.onRefresh = adaptDogsToCellControllers(
            forwardingTo: dogVC,
            imageLoader: imageLoader)
        
        return dogVC
    }
    
    private static func adaptDogsToCellControllers(forwardingTo controller: DogViewController, imageLoader: DogImageDataLoader) -> ([Dog]) -> Void {
        return { [weak controller] dogs in
            controller?.tableModel = dogs.map { dog in
                DogImageCellViewController(model: dog, imageLoader: imageLoader)
            }
        }
    }
}

