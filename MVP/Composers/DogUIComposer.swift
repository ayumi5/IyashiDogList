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
        let presentationAdapter = DogPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: loader))
        dogRefreshVC.delegate = presentationAdapter
        let presenter = DogPresenter(dogLoadingView: WeakRefVirtualProxy(dogRefreshVC), dogView: DogViewAdapter(controller: dogVC, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)))
        presentationAdapter.dogPresenter = presenter
        
        return dogVC
    }
}

private final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: DogLoader where T == DogLoader {
    func load(completion: @escaping (DogLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

extension MainQueueDispatchDecorator: DogImageDataLoader where T == DogImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (DogImageDataLoader.Result) -> Void) -> DogImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
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
