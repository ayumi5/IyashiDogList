//
//  RemoteDogImageDataLoader.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/06/27.
//

import Foundation
import IyashiDogFeature

public final class RemoteDogImageDataLoader: DogImageDataLoader {
    private let client: HTTPClient
    private var task: HTTPClientTask?
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public final class HTTPClientTaskWrapper: DogImageDataLoaderTask {
        var wrapped: HTTPClientTask?
        private var completion: ((DogImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping ((DogImageDataLoader.Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: DogImageDataLoader.Result) {
            completion?(result)
        }
        
        public func cancel() {
            preventFurtherCompletion()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadImageData(from url: URL, completion: @escaping (DogImageDataLoader.Result) -> Void) -> DogImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion: completion)
        
        task.wrapped = client.get(from: url) { result in
            do {
                let (data, response) = try result.get()
                
                guard data.isEmpty == false, response.statusCode == 200 else {
                    task.complete(with: .failure(Error.invalidData))
                    return
                }
                
                task.complete(with: .success(data))
                
            } catch {
                task.complete(with: .failure(error))
            }
        }
                                                   
        return task
    }
    
    public func cancelLoad() {
        task?.cancel()
        task = nil
    }
}
