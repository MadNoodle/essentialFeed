//
//  URLSessionHTTPClientTests.swift
//  essentialFeedTests
//
//  Created by Mathieu Janneau on 04/12/2021.
//

import XCTest
import essentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
    }
    

    func test_getFromURL_performsGETrequestWithURL() {
//        let exp = expectation(description: "receive a valid url and method")
//        URLProtocolStub.observeRequests { request in
//            XCTAssertEqual(request.url, self.anyURL())
//            XCTAssertEqual(request.httpMethod, "GET")
//            exp.fulfill()
//        }
//
//        makeSUT().get(from: anyURL()) { _ in }
//
//        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyError()

        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    

    
    func test_getFromUrl_failsOnAllInvalidRepresentation() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyNonHTTPResponse(), error:nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyNonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyanyHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyNonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyanyHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyNonHTTPResponse(), error: nil))
    }
    
    func test_getFromUrl_succeedsWithHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyanyHTTPResponse()
        let receivedValues = resultvaluesFor(data: data, response: response, error: nil)
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_getFromUrl_succeedsWithHTTPURLResponseWithEmptyData() {
        let response = anyanyHTTPResponse()
        let emptyData = Data()
        let receivedValues = resultvaluesFor(data: emptyData, response: response, error: nil)
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)

        
    }
    // MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://agivenurl.com")!
    }
    
    private func anyData() -> Data {
        return Data(bytes: "anyData".utf8)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyNonHTTPResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyanyHTTPResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)

            switch result {
            case let .failure(error):
                return error
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
                return nil
            }
    }
    
    private func resultvaluesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
            
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "having a result")
        var receivedValues: HTTPClientResult!
        sut.get(from: anyURL()) { result in
            receivedValues = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedValues
    }
    
    
    // MARK: Helpers Method
    private class URLProtocolStub: URLProtocol {
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
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                            client?.urlProtocolDidFinishLoading(self)
                            return requestObserver(request)
                        }
            
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
