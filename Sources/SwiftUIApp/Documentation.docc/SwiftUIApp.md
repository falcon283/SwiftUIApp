# ``SwiftUIApp``

## Overview

SwiftUIApp is a library made of a set of protocols encouraging and guiding you to follow a specific implementation pattern.
The pattern used is a Reducer like ``ViewFeature``. To implement it you need to specify the ``ViewModelFeature/UIEvent``. 
The user interface will notify back the `ViewFeature` so that the `ViewFeature` implementation will switch the event to 
determine the asynchronous work to do.

``ViewModelFeature`` is the base interface. 
When using SwiftUI, you can opt-in in using ``ViewFeature`` so to work with native SwiftUI states and dependencies.

The Framework is Swift 6 💯 compatible.

## Topics

### Presentation Layer

- ``ViewModelFeature``
- ``ViewFeature``
