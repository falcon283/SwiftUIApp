import Testing
import Foundation
import SwiftAppUtilities
@testable import SwiftUIApp

@Suite
struct CancellationBagTest {

  private struct TestId: Hashable { }

  @Test
  func Given_CancellationBag_When_CancellationIsAdded_Then_ClosureIsNotCalled() async throws {
    struct LocalId: Hashable { }

    let sut: CancellationBag = CancellationBag()

    var called = false
    let cancellation = { called = true }

    sut.add(cancellation, isCancelled: { false }, id: TestId())
    sut.add(cancellation, isCancelled: { false }, id: LocalId())

    #expect(called == false)
  }

  @Test
  func Given_CancellationBag_When_CancellationIsRemovedWithDefaultParameter_Then_CancellationClosureIsNotCalled() async throws {
    struct LocalId: Hashable { }

    let sut: CancellationBag = CancellationBag()

    var called = false
    let cancellation = { called = true }

    sut.add(cancellation, isCancelled: { false }, id: TestId())
    sut.remove(id: TestId())

    #expect(called == false)
  }

  @Test
  func Given_CancellationBag_When_CancellationIsRemovedWithCancellingTrue_Then_CancellationClosureIsCalled() async throws {
    struct LocalId: Hashable { }

    let sut: CancellationBag = CancellationBag()

    var called = false
    let cancellation = { called = true }

    sut.add(cancellation, isCancelled: { false }, id: TestId())
    sut.remove(id: TestId(), cancelling: true)

    #expect(called == true)
  }

  @Test
  func Given_CancellationBag_When_CancellationGetsReplaced_Then_PreviousCancellationClosureIsImmediatelyCalled() async throws {

    let sut: CancellationBag = CancellationBag()

    var called = false
    let cancellation = { called = true }

    sut.add(cancellation, isCancelled: { false }, id: TestId())
    sut.add({ }, isCancelled: { false }, id: TestId())

    #expect(called == true)
  }

  @Test
  func Given_CancellationBag_When_BagDeallocate_Then_ClosureIsCalled() async throws {
    struct LocalId: Hashable { }

    var sut: CancellationBag? = CancellationBag()

    var calledCount = 0
    let cancellation = { calledCount += 1 }

    sut?.add(cancellation, isCancelled: { false }, id: TestId())
    sut?.add(cancellation, isCancelled: { false }, id: LocalId())
    sut = nil

    #expect(calledCount == 2)
  }

  @Test
  func Given_CancellationBag_When_WrittenFromMultipleThreads_Then_SendableIsProperlyImplemented() async throws {
    let sut: CancellationBag = CancellationBag()

    await withTaskGroup(of: Void.self) { group in

      for _ in 0..<10000 {
        group.addTask {
          let id = UUID()
          let task = Task { sut.add({ }, isCancelled: { false }, id: id) }
          await task.value
          sut.remove(id: id)
        }
      }
    }
  }
}
