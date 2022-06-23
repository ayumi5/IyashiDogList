//
//  DogPresentationAdapter.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/23.
//

import IyashiDogFeature

final class DogPresentationAdapter: DogRefreshViewControllerDelegate {
    private let dogLoader: DogLoader
    var dogPresenter: DogPresenter?
    
    init(loader: DogLoader) {
        self.dogLoader = loader
    }
    
    func didRequestDogRefresh() {
        dogPresenter?.didStartLoadingFeed()
        dogLoader.load { [weak self] result in
            switch result {
            case let .success(dogs):
                self?.dogPresenter?.didFinishLoading(with: dogs)
            case let .failure(error):
                self?.dogPresenter?.didFinishLoading(with: error)
            }
        }
    }
}
