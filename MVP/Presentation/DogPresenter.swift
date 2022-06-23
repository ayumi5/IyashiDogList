//
//  DogPresenter.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/18.
//

import IyashiDogFeature

protocol DogLoadingView {
    func display(_ viewModel: DogLoadingViewModel)
}

protocol DogView {
    func display(_ viewModel: DogViewModel)
}

final class DogPresenter {
    private let dogLoadingView: DogLoadingView
    private let dogView: DogView
    
    init(dogLoadingView: DogLoadingView, dogView: DogView) {
        self.dogLoadingView = dogLoadingView
        self.dogView = dogView
    }
    
    func didStartLoadingFeed() {
        dogLoadingView.display(DogLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoading(with dogs: [Dog]) {
        dogView.display(DogViewModel(dogs: dogs))
        dogLoadingView.display(DogLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoading(with error: Error) {
        dogLoadingView.display(DogLoadingViewModel(isLoading: false))
    }
}
