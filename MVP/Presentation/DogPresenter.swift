//
//  DogPresenter.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/18.
//

import IyashiDogFeature

protocol DogLoadingView: AnyObject {
    func display(_ isLoading: Bool)
}

protocol DogView {
    func display(_ dogs: [Dog])
}

final class DogPresenter {
    private let dogLoader: DogLoader
    weak var dogLoadingView: DogLoadingView?
    var dogView: DogView?
    
    init(dogLoader: DogLoader) {
        self.dogLoader = dogLoader
    }
    
    func loadDog() {
        dogLoadingView?.display(true)
        dogLoader.load { [weak self] result in
            if let dogs = try? result.get() {
                self?.dogView?.display(dogs)
            }
            self?.dogLoadingView?.display(false)
        }
    }
    
}
