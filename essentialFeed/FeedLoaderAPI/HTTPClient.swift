//
//  HTTPClient.swift
//  essentialFeed
//
//  Created by Mathieu Janneau on 01/12/2021.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
// permet de faire une extension de Alamofire ou URLSession
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
