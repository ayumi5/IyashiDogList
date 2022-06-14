//
//  DogImageViewModel.swift
//  MVVM
//
//  Created by 宇高あゆみ on 2022/06/14.
//

import IyashiDogFeature
import UIKit

final class DogImageViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var task: DogImageDataLoaderTask?
    private let model: Dog
    private let imageLoader: DogImageDataLoader
    var onImageLoad: Observer<UIImage?>?
    var onLoadingStateChange: Observer<Bool>?
    var onShouldRetryVisible: Observer<Bool>?
    
    init(model: Dog, imageLoader: DogImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func loadImage() {
        onLoadingStateChange?(true)
        onShouldRetryVisible?(false)
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            let imageData = try? result.get()
            let image = imageData.map(UIImage.init) ?? nil
            self?.onImageLoad?(image)
            self?.onShouldRetryVisible?((image == nil))
            self?.onLoadingStateChange?(false)
        }
    }
    
    func cancelImageLoad() {
        task?.cancel()
        task = nil
    }
}
