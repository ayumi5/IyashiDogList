//
//  DogImageDataLoader.swift
//  IyashiDogFeature
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import Foundation

public protocol DogImageDataLoaderTask {
    func cancel()
}

public protocol DogImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> DogImageDataLoaderTask
}
