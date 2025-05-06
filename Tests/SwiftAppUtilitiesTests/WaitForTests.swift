import Foundation
import Testing
import SwiftAppUtilities

@Suite
struct WaitForTests {

  @Test
  @MainActor
  func Given_MultipleTasksModifyingAValueOnMainActor_Then_FinalValueCanBeReadViaWaiting() async throws {

    var value = 0

    Task { value += 1 }
    Task { value += 1 }
    Task { value += 1 }
    Task { value += 1 }
    Task { value += 1 }

    #expect(await waiting(value == 5))
  }

  @Test
  @MainActor
  func Given_MultipleDetachedTasksModifyingAValueOnMainActor_Then_FinalValueCanBeReadViaWaiting() async throws {

    @ThreadSafe
    var value = 0
    let criticalSection = $value

    Task.detached { criticalSection.perform { $0 += 1 } }
    Task.detached { criticalSection.perform { $0 += 1 } }
    Task.detached { criticalSection.perform { $0 += 1 } }
    Task.detached { criticalSection.perform { $0 += 1 } }
    Task.detached { criticalSection.perform { $0 += 1 } }

    #expect(await waiting(value == 5))
  }

  @Test
  func Given_MultipleTasksModifyingAValue_Then_FinalValueCanBeReadViaWaiting() async throws {

    @ThreadSafe
    var value = 0
    let criticalSection = $value

    Task { criticalSection.perform { $0 += 1 } }
    Task { criticalSection.perform { $0 += 1 } }
    Task { criticalSection.perform { $0 += 1 } }
    Task { criticalSection.perform { $0 += 1 } }
    Task { criticalSection.perform { $0 += 1 } }

    #expect(await waiting(value == 5))
  }

  @Test
  func Given_MultipleDetachedTasksModifyingAValue_Then_FinalValueCanBeReadViaWaiting() async throws {

    @ThreadSafe
    var value = 0
    let criticalSection = $value

    Task.detached { criticalSection.perform { $0 += 1 } }
    Task.detached { criticalSection.perform { $0 += 1 } }
    Task.detached { criticalSection.perform { $0 += 1 } }
    Task.detached { criticalSection.perform { $0 += 1 } }
    Task.detached { criticalSection.perform { $0 += 1 } }

    #expect(await waiting(value == 5))
  }

  @Test
  @MainActor
  func Given_AStreamOnMainActor_Then_SubscriptionAndCompletionCanBeEvaluatedViaWaiting() async throws {

    let (stream, continuation) = AsyncStream.makeStream(of: Int.self)

    var subscribed = false
    var completed = false
    Task {
      subscribed = true
      for await _ in stream {
        await Task.yield()
      }
      completed = true
    }

    #expect(await waiting(subscribed))

    continuation.yield(1)
    continuation.finish()

    #expect(await waiting(completed))
  }

  func Given_AStream_Then_SubscriptionAndCompletionCanBeEvaluatedViaWaiting() async throws {

    let (stream, continuation) = AsyncStream.makeStream(of: Int.self)

    var subscribed = false
    var completed = false
    Task {
      subscribed = true
      for await _ in stream {
        await Task.yield()
      }
      completed = true
    }

    #expect(await waiting(subscribed))

    continuation.yield(1)
    continuation.finish()

    #expect(await waiting(completed))
  }

  @Test
  @MainActor
  func Given_AStreamInDetachedTaskOnMainActor_Then_SubscriptionAndCompletionCanBeEvaluatedViaWaiting() async throws {

    let (stream, continuation) = AsyncStream.makeStream(of: Int.self)

    var subscribed = false
    var completed = false
    Task.detached {
      subscribed = true
      for await _ in stream {
        await Task.yield()
      }
      completed = true
    }

    #expect(await waiting(subscribed))

    continuation.yield(1)
    continuation.finish()

    #expect(await waiting(completed))
  }

  @Test
  func Given_AStreamInDetachedTask_Then_SubscriptionAndCompletionCanBeEvaluatedViaWaiting() async throws {

    let (stream, continuation) = AsyncStream.makeStream(of: Int.self)

    var subscribed = false
    var completed = false
    Task.detached {
      subscribed = true
      for await _ in stream {
        await Task.yield()
      }
      completed = true
    }

    #expect(await waiting(subscribed))

    continuation.yield(1)
    continuation.finish()

    #expect(await waiting(completed))
  }
}
