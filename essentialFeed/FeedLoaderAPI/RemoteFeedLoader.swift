//
//  RemoteFeedLoader.swift
//  essentialFeed
//
//  Created by Mathieu Janneau on 27/11/2021.
//

import Foundation

// permet de faire une extension de Alamofire ou URLSession
public protocol HTTPClient {
    func get(from url: URL)
}


public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init (url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}

