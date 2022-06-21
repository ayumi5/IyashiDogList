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

protocol DogLoadingView {
    func display(_ viewModel: DogLoadingViewModel)
}

protocol DogView {
    func display(_ viewModel: DogViewModel)
}

final class DogPresenter {
    var dogLoadingView: DogLoadingView?
    var dogView: DogView?
    
    func didStartLoadingFeed() {
        dogLoadingView?.display(DogLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoading(with dogs: [Dog]) {
        dogView?.display(DogViewModel(dogs: dogs))
        dogLoadingView?.display(DogLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoading(with error: Error) {
        dogLoadingView?.display(DogLoadingViewModel(isLoading: false))
    }
}

final class DogPresentationAdapter: DogRefreshViewControllerDelegate {
    private let dogLoader: DogLoader
    private let dogPresenter: DogPresenter
    
    init(loader: DogLoader, presenter: DogPresenter) {
        self.dogLoader = loader
        self.dogPresenter = presenter
    }
    
    func didRequestDogRefresh() {
        dogPresenter.didStartLoadingFeed()
        dogLoader.load { [weak self] result in
            switch result {
            case let .success(dogs):
                self?.dogPresenter.didFinishLoading(with: dogs)
            case let .failure(error):
                self?.dogPresenter.didFinishLoading(with: error)
            }
        }
    }
}
