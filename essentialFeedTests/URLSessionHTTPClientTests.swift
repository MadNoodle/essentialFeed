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
    
    init(session: URLSession = .shared) {
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
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
    }
    func test_getFromURL_performsGETrequestWithURL() {
        let exp = expectation(description: "receive a valid url and method")
        let url = URL(string: "http:givenurl.com")!
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_resumeOnRequestError() {
        let url = URL(string: "http://agivenurl.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let exp =  expectation(description: "Expect request to send Error")
        makeSUT().get(from: url) { result in
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
    
    private func makeSUT() -> URLSessionHTTPClient {
        return URLSessionHTTPClient()
    }
    // MARK: Helpers Method
    private class URLProtocolStub: URLProtocol {
        var receivedURLs = [URL]()
        var reeivedErrors = [Error]()
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(self)
            stub = nil
            requestObserver = nil
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping(URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    


}
