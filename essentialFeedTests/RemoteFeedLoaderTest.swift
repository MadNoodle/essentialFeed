//
//  RemoteFeedLoaderTest.swift
//  essentialFeedTests
//
//  Created by Mathieu Janneau on 27/11/2021.
//

import XCTest
import essentialFeed

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string:"http://given-url.com")!
        let (_ , client) =  makeSut(url: url)
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }

    func test_init_doesRequestDataFromURL() {
        let url = URL(string: "https://a-givenurl.com")!
        let (sut, client) = makeSut(url: url)
        
        sut.load()
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_init_loadTwice_requetedDataFromURL() {
        let url = URL(string: "https://a-givenurl.com")!
        let (sut, client) = makeSut(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSut()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0)}
        let clientError = NSError(domain: "test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    private func makeSut(url: URL = URL(string:"http://given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return(sut, client)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (Error) -> Void)]()
        
        var requestedUrls: [URL] {
            return messages.map { $0.url}
        }
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
}
