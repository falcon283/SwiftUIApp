#if os(iOS) || os(macOS)
import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct MyView: ViewFeature {

  enum UIEvent {
    case buttonTap
    case presentModalTap
    case modalClosed
    case closeButtonTap
    case textField1Changed(String)
    case textField1Focused(Bool)
    case textField2Changed(String)
    case textField2Focused(Bool)
  }

  @Environment(\.dismiss)
  private var dismiss

  @State
  private(set) var presenting: Bool = false

  @FocusStateAdapter
  private(set) var focus1: Bool

  @FocusStateAdapter
  private(set) var focus2: Bool

  @State
  private(set) var writable: String = "Hello World"

  @State
  private(set) var writable2: String = ""

  let backgroundColor = Color(
    red: .random(in: 0...255),
    green: .random(in: 0...255),
    blue: .random(in: 0...255)
  )

  @Environment(\.colorScheme)
  var colorScheme: ColorScheme

  func notify(_ event: UIEvent) async {
    switch event {
    case .buttonTap:
      try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 5)
      guard !Task.isCancelled else { return }
      self.focus1 = false
      self.focus2 = false
      self.writable = "\(Int.random(in: 0...100))"

    case .presentModalTap:
      try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
      guard !Task.isCancelled else { return }
      self.presenting = true

    case .modalClosed:
      self.presenting = false

    case .closeButtonTap:
      self.dismiss()

    case let .textField1Changed(newText):
      print("TextField 1 \(newText)")
      self.writable = newText

    case let .textField2Changed(newText):
      print("TextField 2 \(newText)")
      self.writable2 = newText

    case let .textField1Focused(focused):
      print("Focus 1 \(focused)")
      self.focus1 = focused

    case let .textField2Focused(focused):
      print("Focus 2 \(focused)")
      self.focus2 = focused
    }
  }
}
#endif
