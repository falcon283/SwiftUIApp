import Foundation
import Testing
import SwiftAppUtilities
@testable import SimpleWeather

@Suite
struct URLSessionHTTPClientTests {

  enum TestError: Error {
    case test
  }

  let url = URL(string: "https://test.com").unsafelyUnwrapped

  struct TestEncodable: Encodable {
    let parameter: Int
  }

  struct TestDecodable: Decodable {
    let value: Int
  }

  @Test
  func Given_URLSessionHTTPClient_When_DefaultParametersAreUsed_Then_URLRequestIsGET() async throws {

    @ThreadSafe
    var receivedURLRequest: URLRequest?

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      $receivedURLRequest.assign(request)
      throw TestError.test
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path")

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: [:],
      modifiers: [],
      dataFor: dataClosure
    )

    await #expect(throws: HTTPClientError.self) { try await sut.request(request, payload: .init(parameter: 10)) }

    let urlRequest = try #require(receivedURLRequest)

    #expect(urlRequest.url?.absoluteString == "https://test.com/path?parameter=10")
    #expect(urlRequest.httpMethod == "GET")
    #expect(urlRequest.httpBody == nil)
  }

  @Test
  func Given_URLSessionHTTPClient_When_POSTMethodIsUsed_Then_URLRequestIsPOST() async throws {

    @ThreadSafe
    var receivedURLRequest: URLRequest?

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      $receivedURLRequest.assign(request)
      throw TestError.test
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path", method: .post)

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: [:],
      modifiers: [],
      dataFor: dataClosure
    )

    await #expect(throws: HTTPClientError.self) { try await sut.request(request, payload: .init(parameter: 10)) }

    let urlRequest = try #require(receivedURLRequest)

    #expect(urlRequest.url?.absoluteString == "https://test.com/path")
    #expect(urlRequest.httpMethod == "POST")
    #expect(urlRequest.httpBody == #"{"parameter":10}"#.data(using: .utf8))
  }

  @Test
  func Given_URLSessionHTTPClient_When_PATCHMethodIsUsed_Then_URLRequestIsPATCH() async throws {

    @ThreadSafe
    var receivedURLRequest: URLRequest?

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      $receivedURLRequest.assign(request)
      throw TestError.test
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path", method: .patch)

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: [:],
      modifiers: [],
      dataFor: dataClosure
    )

    await #expect(throws: HTTPClientError.self) { try await sut.request(request, payload: .init(parameter: 10)) }

    let urlRequest = try #require(receivedURLRequest)

    #expect(urlRequest.url?.absoluteString == "https://test.com/path")
    #expect(urlRequest.httpMethod == "PATCH")
    #expect(urlRequest.httpBody == #"{"parameter":10}"#.data(using: .utf8))
  }

  @Test
  func Given_URLSessionHTTPClient_When_PUTMethodIsUsed_Then_URLRequestIsPUT() async throws {

    @ThreadSafe
    var receivedURLRequest: URLRequest?

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      $receivedURLRequest.assign(request)
      throw TestError.test
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path", method: .put)

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: [:],
      modifiers: [],
      dataFor: dataClosure
    )

    await #expect(throws: HTTPClientError.self) { try await sut.request(request, payload: .init(parameter: 10)) }

    let urlRequest = try #require(receivedURLRequest)

    #expect(urlRequest.url?.absoluteString == "https://test.com/path")
    #expect(urlRequest.httpMethod == "PUT")
    #expect(urlRequest.httpBody == #"{"parameter":10}"#.data(using: .utf8))
  }

  @Test
  func Given_URLSessionHTTPClient_When_DELETEMethodIsUsed_Then_URLRequestIsDELETE() async throws {

    @ThreadSafe
    var receivedURLRequest: URLRequest?

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      $receivedURLRequest.assign(request)
      throw TestError.test
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path", method: .delete)

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: [:],
      modifiers: [],
      dataFor: dataClosure
    )

    await #expect(throws: HTTPClientError.self) { try await sut.request(request, payload: .init(parameter: 10)) }

    let urlRequest = try #require(receivedURLRequest)

    #expect(urlRequest.url?.absoluteString == "https://test.com/path")
    #expect(urlRequest.httpMethod == "DELETE")
    #expect(urlRequest.httpBody == #"{"parameter":10}"#.data(using: .utf8))
  }

  @Test
  func Given_URLSessionHTTPClient_When_DefaultHeadersAreUsed_Then_URLRequestContainsHeaders() async throws {

    @ThreadSafe
    var receivedURLRequest: URLRequest?

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      $receivedURLRequest.assign(request)
      throw TestError.test
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path")

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: ["test": "default"],
      modifiers: [],
      dataFor: dataClosure
    )

    await #expect(throws: HTTPClientError.self) { try await sut.request(request, payload: .init(parameter: 10)) }

    let urlRequest = try #require(receivedURLRequest)

    #expect(urlRequest.allHTTPHeaderFields == ["test": "default"])
  }

  @Test
  func Given_URLSessionHTTPClient_When_RequestHeadersAreUsed_Then_URLRequestContainsHeaders() async throws {

    @ThreadSafe
    var receivedURLRequest: URLRequest?

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      $receivedURLRequest.assign(request)
      throw TestError.test
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path", headers: ["test": "header"])

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: [:],
      modifiers: [],
      dataFor: dataClosure
    )

    await #expect(throws: HTTPClientError.self) { try await sut.request(request, payload: .init(parameter: 10)) }

    let urlRequest = try #require(receivedURLRequest)

    #expect(urlRequest.allHTTPHeaderFields == ["test": "header"])
  }

  @Test
  func Given_URLSessionHTTPClient_When_BothDefaultAndRequestHeadersAreUsed_Then_URLRequestContainsAllHeaders() async throws {

    @ThreadSafe
    var receivedURLRequest: URLRequest?

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      $receivedURLRequest.assign(request)
      throw TestError.test
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path", headers: ["request": "header"])

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: ["test":"header"],
      modifiers: [],
      dataFor: dataClosure
    )

    await #expect(throws: HTTPClientError.self) { try await sut.request(request, payload: .init(parameter: 10)) }

    let urlRequest = try #require(receivedURLRequest)

    #expect(urlRequest.allHTTPHeaderFields == ["test": "header", "request": "header"])
  }

  @Test
  func Given_URLSessionHTTPClient_When_RequestHeadersOverrider_Then_URLRequestContainsRequestHeader() async throws {

    @ThreadSafe
    var receivedURLRequest: URLRequest?

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      $receivedURLRequest.assign(request)
      throw TestError.test
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path", headers: ["test": "request"])

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: ["test":"default"],
      modifiers: [],
      dataFor: dataClosure
    )

    await #expect(throws: HTTPClientError.self) { try await sut.request(request, payload: .init(parameter: 10)) }

    let urlRequest = try #require(receivedURLRequest)

    #expect(urlRequest.allHTTPHeaderFields == ["test": "request"])
  }

  @Test
  func Given_URLSessionHTTPClient_When_RequestIsSucceed_Then_PayloadIsReceived() async throws {

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      (
        #"{ "value": 10 }"#.data(using: .utf8).unsafelyUnwrapped,
        HTTPURLResponse(
          url: request.url.unsafelyUnwrapped,
          mimeType: nil,
          expectedContentLength: 0,
          textEncodingName: nil
        )
      )
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path")

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: [:],
      modifiers: [],
      dataFor: dataClosure
    )

    let result = try await sut.request(request, payload: .init(parameter: 10))

    #expect(result.value == 10)
  }

  @Test
  func Given_URLSessionHTTPClient_When_ModifierIsUsed_Then_URLRequestIsModified() async throws {

    @ThreadSafe
    var receivedURLRequest: URLRequest?

    let dataClosure: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
      $receivedURLRequest.assign(request)
      throw TestError.test
    }

    let request = HTTPRequest<TestEncodable, TestDecodable>(path: "path")

    let sut = URLSessionHTTPClient(
      baseURL: self.url,
      defaultHeaders: [:],
      modifiers: [{ $0.allHTTPHeaderFields = ["modified": "headers"] }],
      dataFor: dataClosure
    )

    await #expect(throws: HTTPClientError.self) { try await sut.request(request, payload: .init(parameter: 10)) }

    let urlRequest = try #require(receivedURLRequest)

    #expect(urlRequest.allHTTPHeaderFields == ["modified": "headers"])
  }
}
