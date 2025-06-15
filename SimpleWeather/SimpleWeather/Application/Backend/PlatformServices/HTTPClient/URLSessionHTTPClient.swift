import Foundation

struct URLSessionHTTPClient: HTTPClient {

  typealias ModifierClosure = @Sendable (inout URLRequest) async -> Void

  private let baseURL: URL
  private let defaultHeaders: [String: String]
  private var modifiers: [ModifierClosure] = []
  private let dataFor: @Sendable (URLRequest) async throws -> (Data, URLResponse)

  init(
    baseURL: URL,
    defaultHeaders: [String : String],
    modifiers: [ModifierClosure],
    dataFor: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)
  ) {
    self.baseURL = baseURL
    self.defaultHeaders = defaultHeaders
    self.modifiers = modifiers
    self.dataFor = dataFor
  }

  func request<Payload, DTO>(
    _ request: HTTPRequest<Payload, DTO>,
    payload: Payload
  ) async throws(HTTPClientError) -> DTO where Payload : Encodable, DTO : Decodable {

    let urlRequest = await URLRequest
      .buildURLRequest(for: request, baseURL: self.baseURL, defaultHeaders: self.defaultHeaders)
      .applyCustomModifiers(self.modifiers)
      .encodePayload(for: request, payload: payload)

    let result: (data: Data, response: URLResponse)
    do {
      result = try await self.dataFor(urlRequest)
    } catch {
      throw .requestError(error)
    }

    do {
      return try request.decoder.decode(DTO.self, from: result.data)
    } catch {
      throw .decodingError(error, response: result.response)
    }
  }
}

private extension URLRequest {

  static func buildURLRequest<Payload: Encodable, DTO: Decodable>(
    for request: HTTPRequest<Payload, DTO>,
    baseURL: URL,
    defaultHeaders: [String: String]
  ) -> URLRequest {
    let url: URL
    if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
      url = baseURL.appending(path: request.path)
    } else {
      url = baseURL.appendingPathComponent(request.path)
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method.urlSessionMethod
    urlRequest.allHTTPHeaderFields = defaultHeaders.merging(request.headers) { $1 }
    return urlRequest
  }

  func applyCustomModifiers(_ modifiers: [URLSessionHTTPClient.ModifierClosure]) async -> URLRequest {
    var updated = self
    for modify in modifiers { await modify(&updated) }
    return updated
  }

  func encodePayload<Payload: Encodable, DTO: Decodable>(for request: HTTPRequest<Payload, DTO>, payload: Payload) -> URLRequest {
    var urlRequest = self
    switch request.method {
    case .get:
      guard let url = urlRequest.url,
            let data = try? request.encoder.encode(payload),
            let dictionary = try? request.decoder.decode([String: QueryValue].self, from: data),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
      else { return self }

      components.queryItems = dictionary.map { URLQueryItem(name: $0, value: $1.stringValue) }
      urlRequest.url = components.url

    case .post,
         .put,
         .patch,
         .delete:
      urlRequest.httpBody = try? request.encoder.encode(payload)
    }

    return urlRequest
  }
}

private extension HTTPRequest.Method {

  var urlSessionMethod: String {
    switch self {
    case .get:
      return "GET"
    case .post:
      return "POST"
    case .put:
      return "PUT"
    case .patch:
      return "PATCH"
    case .delete:
      return "DELETE"
    }
  }
}

private enum QueryValue: Decodable {
  case string(String)
  case integer(Int)
  case double(Double)

  init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let stringValue = try? container.decode(String.self) {
      self = .string(stringValue)
    } else if let numberValue = try? container.decode(Int.self) {
      self = .integer(numberValue)
    } else {
      let numberValue = try container.decode(Double.self)
      self = .double(numberValue)
    }
  }
}

private extension QueryValue {

  var stringValue: String {
    switch self {
    case let .string(value):
      return value
    case let .integer(value):
      return String(value)
    case let .double(value):
      return String(value)
    }
  }
}
