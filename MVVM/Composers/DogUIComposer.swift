//
//  DogUIComposer.swift
//  MVVM
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
        let dogViewModel = DogViewModel(dogLoader: loader)
        dogViewModel.onLoadDog = adaptDogsToCellControllers(
            forwardingTo: dogVC,
            imageLoader: imageLoader)
        let dogRefreshVC = dogVC.dogRefreshViewController
        dogRefreshVC?.dogViewModel = dogViewModel
        
        return dogVC
    }
    
    private static func adaptDogsToCellControllers(forwardingTo controller: DogViewController, imageLoader: DogImageDataLoader) -> ([Dog]) -> Void {
        return { [weak controller] dogs in
            controller?.tableModel = dogs.map { dog in
                return DogImageCellViewController(viewModel: DogImageViewModel(model: dog, imageLoader: imageLoader))
            }
        }
    }
}

