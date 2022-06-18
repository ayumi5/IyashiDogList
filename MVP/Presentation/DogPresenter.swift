//
//  DogPresenter.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/18.
//

import IyashiDogFeature

struct DogLoadingViewModel {
    var isLoading: Bool
}

struct DogViewModel {
    var dogs: [Dog]
}

protocol DogLoadingView: AnyObject {
    func display(_ viewModel: DogLoadingViewModel)
}

protocol DogView {
    func display(_ viewModel: DogViewModel)
}

final class DogPresenter {
    private let dogLoader: DogLoader
    weak var dogLoadingView: DogLoadingView?
    var dogView: DogView?
    
    init(dogLoader: DogLoader) {
        self.dogLoader = dogLoader
    }
    
    func loadDog() {
        dogLoadingView?.display(DogLoadingViewModel(isLoading: true))
        dogLoader.load { [weak self] result in
            if let dogs = try? result.get() {
                self?.dogView?.display(DogViewModel(dogs: dogs))
            }
            self?.dogLoadingView?.display(DogLoadingViewModel(isLoading: false))
        }
    }
    
}
