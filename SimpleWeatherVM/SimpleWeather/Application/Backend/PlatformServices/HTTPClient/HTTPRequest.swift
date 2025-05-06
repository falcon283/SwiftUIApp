import Foundation

struct HTTPRequest<Payload: Encodable, DTO: Decodable> {

  enum Method {
    case get
    case post
    case put
    case patch
    case delete
  }

  var baseURL: String? = nil
  let path: String
  var method: Method = .get
  var headers: [String: String] = [:]
  var encoder: JSONEncoder = JSONEncoder()
  var decoder: JSONDecoder = JSONDecoder()
}

extension HTTPRequest {
  var asHashable: AnyHashable {
    var hasher = Hasher()
    hasher.combine(self.baseURL)
    hasher.combine(self.path)
    hasher.combine(self.method)
    hasher.combine(self.headers)
    return AnyHashable(hasher.finalize())
  }
}
