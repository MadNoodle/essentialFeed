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
        
        sut.load { _ in }
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_init_loadTwice_requetedDataFromURL() {
        let url = URL(string: "https://a-givenurl.com")!
        let (sut, client) = makeSut(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSut()
        
        expect(sut, toCompleteError: .connectivity) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNo200HTTPResponse() {
        let (sut, client) = makeSut()
        
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0)}
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    func test_load_delivers_anInvalidJSON() {
        let (sut, client) = makeSut()
        expect(sut, toCompleteError: .invalidData) {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    private func makeSut(url: URL = URL(string:"http://given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return(sut, client)
        
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load {capturedErrors.append($0)}
        
        action()
        
        XCTAssertEqual(capturedErrors, [error], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: ( HTTPClientResult) -> Void)]()
        
        var requestedUrls: [URL] {
            return messages.map { $0.url}
        }
        
        func get(from url: URL, completion: @escaping ( HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedUrls[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
