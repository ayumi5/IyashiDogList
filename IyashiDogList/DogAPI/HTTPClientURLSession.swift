//
//  HTTPClientURLSession.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/24.
//

import Foundation

public final class HTTPClientURLSession: HTTPClient {
    private let session: URLSession
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct InvalidResponseError: Error {}
    
    private struct URLSessionWrapper: HTTPClientTask {
        var wrapped: URLSessionDataTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(InvalidResponseError()))
            }
        }
        task.resume()
        return  URLSessionWrapper(wrapped: task)
    }
}
