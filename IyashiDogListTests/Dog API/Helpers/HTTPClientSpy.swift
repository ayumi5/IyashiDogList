//
//  HTTPClientSpy.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/27.
//

import Foundation
import IyashiDogList


final class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    var cancelledURLs = [URL]()
    private var completions = [(HTTPClient.Result) -> Void]()
    
    struct TaskSpy: HTTPClientTask {
        var action: () -> Void
        func cancel() {
            action()
        }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        requestedURLs.append(url)
        completions.append(completion)
        
        return TaskSpy(action: { [weak self] in
            self?.cancelledURLs.append(url)
        })
    }
    
    func complete(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        completions[index](.success((data, response)))
    }
}
