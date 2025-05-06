import Foundation

struct OpenURLService: Sendable {

  private let open: @Sendable (URL) -> Void

  init(open: @escaping @Sendable (URL) -> Void) {
    self.open = open
  }

  func callAsFunction(_ url: URL) {
    self.open(url)
  }
}
