//
//  URLSessionHTTPClientTests.swift
//  essentialFeedTests
//
//  Created by Mathieu Janneau on 04/12/2021.
//

import XCTest
import essentialFeed

class URLSessionHTTPClient {
    private var session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult)-> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
            
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumeDatataskWithUrl() {
        let url = URL(string: "http://agivenurl.com")!
        let task = URLSessionDataTaskSpy()
        let session = URLSessionSpy()
        
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { result in}
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_resumeOnRequestError() {
        let url = URL(string: "http://agivenurl.com")!
        let error = NSError(domain: "any error", code: 1)
        let session = URLSessionSpy()
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp =  expectation(description: "Expect request to send Error")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure")
            }
        }
        exp.fulfill()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    

    // MARK: Helpers Method
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        var reeivedErrors = [Error]()
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeUrlSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError(")Couldn't find a stub for this \(url)")
            }
                                                          
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeUrlSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }

}
