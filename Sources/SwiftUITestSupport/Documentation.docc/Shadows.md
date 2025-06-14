# SwiftUI Shadows

## Overview

These are the SwiftUI types that are shadowed by the test support types.
If your SwiftUI Views swift file will import `SwiftUITestSupport` then all the SwiftUI property wrappers will be replaced by 
the shadows so to enable Unit Testing of your View implementation.
All the implementations are wrapped into a pre-compiler macro available only for `Debug` builds. 
This ensure that is impossible to use the SwiftUI Shadows in `Release` builds.

Mind: All the Shadowed property wrappers have been stripped of the `projectedValues` (`Bindings`).
The reason for this is that we want to avoid the `body` freely mutating the state in an untestable way using the Binding.
See `SwiftUIApp` to deep dive into the topic.

Documentation of each Shadows is 100% taken from SwiftUI code documentation.

## Topics 

### State Management
- ``State``
- ``StateObject``

### Environment

- ``Environment``
- ``EnvironmentObject``

### UserDefault
- ``AppStorage``
- ``SceneStorage``

### Focus
- ``AccessibilityFocusState``
- ``FocusedBinding``
- ``FocusedObject``
- ``FocusedValue``
- ``FocusState``

### CoreData
- ``FetchRequest``
- ``FetchedResults``
- ``SectionedFetchRequest``
- ``SectionedFetchResults``

### Other
- ``ScaledMetric``
