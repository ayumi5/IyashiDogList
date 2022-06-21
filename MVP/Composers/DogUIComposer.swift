//
//  DogUIComposer.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/04.
//

import Foundation
import IyashiDogFeature
import UIKit

public final class DogUIComposer {
    private init() {}
    
    static public func dogComposed(with loader: DogLoader, imageLoader: DogImageDataLoader) -> DogViewController {
        let bundle = Bundle(for: DogViewController.self)
        let storyboard = UIStoryboard(name: "Dog", bundle: bundle)
        let dogVC = storyboard.instantiateInitialViewController() as! DogViewController
        let dogRefreshVC = dogVC.dogRefreshViewController!
        let presentationAdapter = DogPresentationAdapter(loader: loader)
        dogRefreshVC.delegate = presentationAdapter
        let presenter = DogPresenter(dogLoadingView: WeakRefVirtualProxy(dogRefreshVC), dogView: DogViewAdapter(controller: dogVC, imageLoader: imageLoader))
        presentationAdapter.dogPresenter = presenter
        
        return dogVC
    }
}

private final class DogViewAdapter: DogView {
    private weak var controller: DogViewController?
    private let imageLoader: DogImageDataLoader
    
    init(controller: DogViewController, imageLoader: DogImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: DogViewModel) {
        controller?.tableModel = viewModel.dogs.map { dog in
            let adapter = DogImagePresentationAdapter<WeakRefVirtualProxy<DogImageCellViewController>, UIImage>(model: dog, loader: imageLoader)
            let imageCell = DogImageCellViewController(delegate: adapter)
            let presenter = DogImagePresenter(view: WeakRefVirtualProxy(imageCell), imageTransformer: UIImage.init)
            adapter.presenter = presenter
            return imageCell
        }
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: DogLoadingView where T: DogLoadingView {
    func display(_ viewModel: DogLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: DogImageView where T: DogImageView, T.Image == UIImage {
    func display(_ viewModel: DogImageViewModel<UIImage>) {
        object?.display(viewModel)
    }
}

