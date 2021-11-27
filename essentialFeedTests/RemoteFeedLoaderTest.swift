//
//  RemoteFeedLoaderTest.swift
//  essentialFeedTests
//
//  Created by Mathieu Janneau on 27/11/2021.
//

import XCTest

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

protocol HTTPClient {
    func get(from url: URL)
}



class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string:"http://given-url.com")!
        let (_ , client) =  makeSut(url: url)
        
        XCTAssertNil(client.requestedURL)
    }

    func test_init_doesRequestDataFromURL() {
        let url = URL(string: "https://a-givenurl.com")!
        let (sut, client) = makeSut(url: url)
        
        sut.load()
        XCTAssertEqual(client.requestedURL, url)
    }
    
    private func makeSut(url: URL = URL(string:"http://given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return(sut, client)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
