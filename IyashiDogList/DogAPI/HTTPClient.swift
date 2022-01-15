//
//  HTTPClient.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/15.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult?) -> Void)
}
