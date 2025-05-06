public struct CancellationBagView<Content: View>: View {

  private let contentView: (CancellationBag) -> Content

  init(@ViewBuilder contentView: @escaping (CancellationBag) -> Content) {
    self.contentView = contentView
  }

  public var body: some View {
    if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
      CancellationBagStateObjectView(contentView: self.contentView)
    } else {
      CancellationBagStateView(contentView: self.contentView)
    }
  }
}

// MARK: - CancellationBag Views

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct CancellationBagStateObjectView<Content: View>: View {

  @StateObject
  private var bag = CancellationBag()

  private let contentView: (CancellationBag) -> Content

  init(contentView: @escaping (CancellationBag) -> Content) {
    self.contentView = contentView
  }

  var body: some View {
    self.contentView(self.bag)
  }
}

private struct CancellationBagStateView<Content: View>: View {

  @State
  private var bag = CancellationBag()

  private let contentView: (CancellationBag) -> Content

  init(contentView: @escaping (CancellationBag) -> Content) {
    self.contentView = contentView
  }

  var body: some View {
    self.contentView(self.bag)
  }
}
