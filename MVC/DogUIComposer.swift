//
//  DogUIComposer.swift
//  MVC
//
//  Created by 宇高あゆみ on 2022/06/04.
//

import Foundation
import IyashiDogFeature

public final class DogUIComposer {
    private init() {}
    
    static public func dogComposed(with loader: DogLoader, imageLoader: DogImageDataLoader) -> DogViewController {
        let dogRefreshVC = DogRefreshViewController(dogLoader: loader)
        let dogVC = DogViewController.init(dogRefreshViewController: dogRefreshVC)
        dogRefreshVC.onRefresh = { [weak dogVC] dogs in
            dogVC?.tableModel = dogs.map { dog in
                    DogImageCellViewController(model: dog, imageLoader: imageLoader)
            }
        }
        
        return dogVC
    }
}
