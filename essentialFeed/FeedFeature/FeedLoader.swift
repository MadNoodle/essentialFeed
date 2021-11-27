//
//  FeedLaoder.swift
//  essentialFeed
//
//  Created by Mathieu Janneau on 27/11/2021.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping((LoadFeedResult) -> Void))
}

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init (url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

// permet de faire une extension de Alamofire ou URLSession
protocol HTTPClient {
    func get(from url: URL)
}
