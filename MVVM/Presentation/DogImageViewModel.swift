//
//  DogImageViewModel.swift
//  MVVM
//
//  Created by 宇高あゆみ on 2022/06/14.
//

import IyashiDogFeature
import Foundation

final class DogImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: DogImageDataLoaderTask?
    private let model: Dog
    private let imageLoader: DogImageDataLoader
    var onImageLoad: Observer<Image?>?
    var onLoadingStateChange: Observer<Bool>?
    var onShouldRetryVisible: Observer<Bool>?
    let imageTransformer: (Data) -> Image?
    
    init(model: Dog, imageLoader: DogImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    func loadImage() {
        onLoadingStateChange?(true)
        onShouldRetryVisible?(false)
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            self?.handleImage(result: result)
        }
    }
    
    func cancelImageLoad() {
        task?.cancel()
        task = nil
    }
    
    private func handleImage(result: DogImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryVisible?(true)
        }
        
        onLoadingStateChange?(false)
    }
}
