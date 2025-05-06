import Foundation

enum HTTPClientError: Error {
  case requestError(Error)
  case decodingError(Error, response: URLResponse)
}

protocol HTTPClient: Sendable {

  func request<Payload: Encodable, DTO: Decodable>(_ request: HTTPRequest<Payload, DTO>, payload: Payload) async throws(HTTPClientError) -> DTO
}

extension HTTPClient {

  func request<DTO: Decodable>(_ request: HTTPRequest<Empty, DTO>) async throws(HTTPClientError) -> DTO {
    try await self.request(request, payload: Empty())
  }
}
