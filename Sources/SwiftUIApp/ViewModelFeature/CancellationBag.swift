internal import SwiftAppUtilities

public final class CancellationBag: @unchecked Sendable, ObservableObject, Equatable {

  private let lock = NSRecursiveLock()
  private var closures: [AnyHashable: (cancel: () -> Void, isCancelled: () -> Bool)] = [:]

  public init() { }

  deinit {
    self.lock.lock(); defer { self.lock.unlock() }
    self.closures.forEach { _, closures in closures.cancel() }
  }

  public func add(_ cancel: @escaping () -> Void, isCancelled: @escaping () -> Bool, id: AnyHashable) {
    self.lock.lock(); defer { self.lock.unlock() }
    self.removeWithoutLocking(id: id, cancelling: true)
    if !isCancelled() {
      self.closures[id] = (cancel, isCancelled)
    }
  }
  
  public func remove(id: AnyHashable, cancelling: Bool = false) {
    self.lock.lock(); defer { self.lock.unlock() }
    self.removeWithoutLocking(id: id, cancelling: cancelling)
  }

  private func removeWithoutLocking(id: AnyHashable, cancelling: Bool) {
    if cancelling { self.closures[id]?.cancel() }
    self.closures[id] = nil
  }

  public static func ==(lhs: CancellationBag, rhs: CancellationBag) -> Bool {
    Set(lhs.closures.keys) == Set(rhs.closures.keys)
  }
}

public extension Task {

  func store(in bag: CancellationBag, with id: AnyHashable) {
    bag.add(self.cancel, isCancelled: { self.isCancelled }, id: id)
  }
}
