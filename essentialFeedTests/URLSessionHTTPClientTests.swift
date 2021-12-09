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
    
    
    func test_getFromURL_resumeOnRequestError() {
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "http://agivenurl.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(url: url, error: error)
        let sut = URLSessionHTTPClient()
        
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
        URLProtocolStub.stopInterceptingRequest()
    }
    
    

    // MARK: Helpers Method
    private class URLProtocolStub: URLProtocol {
        var receivedURLs = [URL]()
        var reeivedErrors = [Error]()
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(self)
        }
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            
            return URLProtocolStub.stubs[url] != nil
            
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    


}
