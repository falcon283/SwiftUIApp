internal import SwiftAppUtilities

/// An object responsible to handle cancellation tasks once it gets destroyed.
///
/// You use such bag to tightly couple the lifetime of a cancellable operation, i.e ``_Concurrency/Task``, to the lifetime of the `CancellationBag`.
/// The `CancellationBag` cancel all the stored `Tasks` as soon as the bag gets deallocated.
///
/// You are responsible for managing the lifetime of the `CancellationBag` which will affect the lifetime of your enqueued cancellable operations.
/// In some rare cases, where fine control is needed, you might want the `CancellationBag` stop tracking the specific cancellable operation.
/// To do so provide the associated `id` to ``remove(id:cancelling:)`` along with `cancelling = false` parameter.
///
/// When using a ``_Concurrency/Task`` you can use instead the helper ``_Concurrency/Task/store(in:with:)`` to embed the task into the bag.
/// When a cancellation gets added with the given `id`, if an operation with the same `id` exists, it gets immediately cancelled and the new one is stored.
///
/// - Note: When used in ``SwiftUICore/View`` it must be made a `@StateObject`, or `@State` if not available, so to tight the bag lifetime
/// to the View lifetime correctly.
public final class CancellationBag: @unchecked Sendable, ObservableObject, Equatable {

  private let lock = NSRecursiveLock()
  private var closures: [AnyHashable: (cancel: () -> Void, isCancelled: () -> Bool)] = [:]

  /// Designated initializer
  public init() { }

  deinit {
    self.lock.lock(); defer { self.lock.unlock() }
    self.closures.forEach { _, closures in closures.cancel() }
  }

  /// Add new cancellable operation to keep track of.
  ///
  /// Once you add the cancellation operation to the `CancellationBag`, it would hold it so that if the bag itself gets deallocated all the holding in flight tasks
  /// are automatically cancelled.
  ///
  /// - Parameters:
  ///   - cancel: The cancellation closure. When called the operation gets asked to be canceled.
  ///   - isCancelled: The is cancelled closure. When called the operations gets asked to know if is cancelled or not.
  ///   - id: The id used to keep track of the closures.
  public func add(_ cancel: @escaping () -> Void, isCancelled: @escaping () -> Bool, id: AnyHashable) {
    self.lock.lock(); defer { self.lock.unlock() }
    self.removeWithoutLocking(id: id, cancelling: true)
    if !isCancelled() {
      self.closures[id] = (cancel, isCancelled)
    }
  }
  
  /// Remove the cancellation associated with the `id`.
  ///
  /// This method should be rarely used. It's supposed to be used if you want to revoke the tracking from the bag and continue with manual cancellation
  /// handling instead.
  ///
  /// - Parameter id: The associated `id` of the tracked cancellable operation you want to remove from the bag.
  /// - Parameter cancelling: If `true` the removed cancellable operation is immediately canceled. Default `false`.
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

  /// Convenience method to keep track of the Task into the ``CancellationBag``
  /// - Parameters:
  ///   - bag: The bag where to insert the Task.
  ///   - id: The id to use to keep track of the Task cancellation.
  func store(in bag: CancellationBag, with id: AnyHashable) {
    bag.add(self.cancel, isCancelled: { self.isCancelled }, id: id)
  }
}
