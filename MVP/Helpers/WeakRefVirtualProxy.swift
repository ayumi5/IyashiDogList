//
//  WeakRefVirtualProxy.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/27.
//

import Foundation
import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
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

