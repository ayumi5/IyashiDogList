//
//  DogImagePresenter.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/21.
//

import Foundation
import IyashiDogFeature

protocol DogImageView {
    associatedtype Image
    
    func display(_ viewModel: DogImageViewModel<Image>)
}

final class DogImagePresenter<View: DogImageView, Image> where View.Image == Image {
    typealias Observer<T> = (T) -> Void
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingDogImage() {
        view.display(DogImageViewModel(image: nil, isLoading: true, shouldRetry: false))
    }
    
    func didFinishLoading(with data: Data) {
        if let image = imageTransformer(data) {
            view.display((DogImageViewModel(image: image, isLoading: false, shouldRetry: false)))
        } else {
            view.display((DogImageViewModel(image: nil, isLoading: false, shouldRetry: true)))
        }
    }
    
    func didFinishLoading(with error: Error) {
        view.display((DogImageViewModel(image: nil, isLoading: false, shouldRetry: true)))
    }
}
