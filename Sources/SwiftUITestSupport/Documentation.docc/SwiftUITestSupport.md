# ``SwiftUITestSupport``

## Overview

When starting Xcode using `SWIFTUIAPP_TEST_SUPPORT=TRUE` environment value and you are building for `Debug`, this
framework will contains Unit Test friendly reimplementations of SwiftUI `DynamicProperty` property wrappers.
In all the other cases that implementations will be evicted from the library entirely so to make sure they will 
not leak unintentionally.

You usually `import SwiftUIApp` to implement a `ViewFeature`. When doing so, `import SwiftUIApp` will also 
transparently `import SwiftUITestSupport` as well so you don't have to do anything to enable the Shadows replacement.
Just start coding using SwiftUI as you normally do.

## Topics

## Unit Test Injection

- ``Injector``
- ``CoreDataInjector``

### Test Support

- ``TestSupport``
- ``given(_:withDependencies:expect:)``

### SwiftUI Shadows

- <doc:Shadows>
