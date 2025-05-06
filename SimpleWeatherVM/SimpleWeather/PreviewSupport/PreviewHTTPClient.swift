import Foundation
import SwiftAppUtilities

struct PreviewHTTPClient: HTTPClient, Sendable {

  enum MockError: Error {
    case invalidDTOType(String)
  }

  @ThreadSafe
  private var responses = [AnyHashable: Result<Any, HTTPClientError>]()

  @discardableResult
  func add<Payload: Encodable, DTO: Decodable>(
    request: HTTPRequest<Payload, DTO>,
    result: Result<DTO, HTTPClientError>
  ) -> PreviewHTTPClient {

    self.$responses.perform { $0[request.asHashable] = result.map { $0 as Any } }
    return self
  }

  func request<Payload, DTO>(
    _ request: HTTPRequest<Payload, DTO>,
    payload: Payload
  ) async throws(HTTPClientError) -> DTO where Payload : Encodable, DTO : Decodable {

    let dto = try self.responses[request.asHashable]?.get()
    if let dto = dto as? DTO {
      return dto
    } else {
      let url = URL(string: NSString(string: "https://test.com").appendingPathComponent(request.path)).unsafelyUnwrapped
      throw .decodingError(
        MockError.invalidDTOType("Found \(type(of: dto)) but \(String(describing: DTO.self)) was expected"),
        response: HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
      )
    }
  }
}
