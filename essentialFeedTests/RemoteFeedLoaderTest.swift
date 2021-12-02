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
        
        expect(sut, toCompleteResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    
    func test_load_deliversErrorOnNo200HTTPResponse() {
        let (sut, client) = makeSut()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteResult: .failure(.invalidData)) {
                let json = makeItemsJson([])
                client.complete(withStatusCode: code,data: json, at: index)
            }
        }
    }
    
    func test_load_delivers_anInvalidJSON() {
        let (sut, client) = makeSut()
        expect(sut, toCompleteResult: .failure(.invalidData)) {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    func test_load_delivers_emptyJSON() {
        let (sut, client) = makeSut()
        expect(sut, toCompleteResult: .success([])) {
            let empltyListJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: empltyListJSON)
        }
    }
    
    func test_load_delivers_FeedItems() {
        let (sut, client) = makeSut()
        
        let item1 = makeItem(uuid: UUID(),
                             imageURL: URL(string: "http://asingleimage.com")!
        )
        
        
        let item2 = makeItem(uuid: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "http://asingleimage.com")!)
        
        let items = [item1.model, item2.model]
        expect(sut, toCompleteResult: .success(items)) {
            let jsonData = makeItemsJson([item1.jsonRepresentation, item2.jsonRepresentation])
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }
    
    
    // HELPERS METHODS
    private func makeSut(url: URL = URL(string:"http://given-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        return(sut, client)
        
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated", file: file, line: line)
        }
    }
    
    private func makeItem(uuid: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, jsonRepresentation: [String: Any]) {
        let item = FeedItem(id: uuid, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": uuid.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value {acc[e.key] = value}
        }
        return (item, json)
    }
    
    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedErrors = [RemoteFeedLoader.Result]()
        sut.load {capturedErrors.append($0)}
        
        action()
        
        XCTAssertEqual(capturedErrors, [result], file: file, line: line)
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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedUrls[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
