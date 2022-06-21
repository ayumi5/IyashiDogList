//
//  DogImagePresenter.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/21.
//

import Foundation
import IyashiDogFeature
import UIKit

struct DogImageViewModel<Image> {
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
}

protocol DogImageView {
    associatedtype Image
    
    func display(_ viewModel: DogImageViewModel<Image>)
}

final class DogImagePresentationAdapter<View: DogImageView, Image>: DogImageCellViewControllerDelegate where View.Image == Image {
    private let loader: DogImageDataLoader
    private let model: Dog
    var presenter: DogImagePresenter<View, Image>?
    private var task: DogImageDataLoaderTask?
    
    init(model: Dog, loader: DogImageDataLoader) {
        self.model = model
        self.loader = loader
    }
    
    func loadDogImage() {
        presenter?.didStartLoadingDogImage()
        task = loader.loadImageData(from: model.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoading(with: data)
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
    
    func cancelLoad() {
        task?.cancel()
        task = nil
    }
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
