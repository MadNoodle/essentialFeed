//
//  RemoteFeedLoaderTest.swift
//  essentialFeedTests
//
//  Created by Mathieu Janneau on 27/11/2021.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.sharedInstance.requestedURL = URL(string: "http://a-url.com")
    }
}

class HTTPClient {
    static let sharedInstance = HTTPClient()
    private init() {}
    var requestedURL: URL?
}

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.sharedInstance
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }

    func test_init_doesRequestDataFromURL() {
        let client = HTTPClient.sharedInstance
        let sut = RemoteFeedLoader()
        
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}
