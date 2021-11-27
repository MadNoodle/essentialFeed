//
//  RemoteFeedLoaderTest.swift
//  essentialFeedTests
//
//  Created by Mathieu Janneau on 27/11/2021.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.sharedInstance.get(from: URL(string: "http://a-url.com")!)
    }
}

class HTTPClient {
    // var allows to mock
    static var sharedInstance = HTTPClient()
    func get(from url: URL) {
    }
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.sharedInstance = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }

    func test_init_doesRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.sharedInstance = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}
