//
//  DogImagePresentationAdapter.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/23.
//

import IyashiDogFeature

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
