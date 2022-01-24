//
//  HTTPClientURLSession.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/24.
//

import Foundation

public class HTTPClientURLSession {
    public init() {}
    
    private struct InvalidResponseError: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult?) -> Void) {
        URLSession.shared.dataTask(with: url) {data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(InvalidResponseError()))
            }
        }.resume()
    }
}
