//
//  RemoteFeedLoader.swift
//  essentialFeed
//
//  Created by Mathieu Janneau on 27/11/2021.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init (url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result)-> Void) {
        client.get(from: url) {[weak self] result in
            guard self != nil else { return}
            
            switch result {
            case .success(let data, let response):
                completion(FeedItemMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
            
        }
    }
    
}


