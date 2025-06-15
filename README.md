[![GitHub Pages](https://img.shields.io/badge/docs-GitHub%20Pages-blue?logo=github)](https://falcon283.github.io/SwiftUIApp/)

# SwiftUIApp

SwiftUIApp is tiny library with the goal of enabling writing consistent Native SwiftUI code.

## Purpose

This project began as a research initiative to explore alternatives of using TCA (The Composable Architecture) for building SwiftUI apps. While TCA offers powerful features like `send(action:)` and Reducers to manage business logic, composability, and testability, there are scenarios where using it might not be feasible, such as:

- Preventing tight coupling with a complex library pattern.
- Simplifying onboarding for new developers by reducing conceptual overhead.
- Other project-specific constraints.

So what's different in `SwiftUIApp`?
The library goal is to be as much possible transparent while using SwiftUI. 
The core concept is based on a single protocol, `ViewFeature`, which is meant as guardrail and enable you consistently 
build new UI Features following always the same approach.

If your will is to use UIKit, or in general you prefer the `VM` approach, then the `ViewModelFeature` protocol share 
the same goals and guardrail.

Additionally, you can opt-it, but only for `Debug` builds, to enable `SwiftUI` to be **Unit Test friendly**.
This will be a game changer if you want to adopt the `ViewFeature` protocol as you coding style since you will be able 
to 100% test your `ViewFeature` business logic implementation keeping a consistent Unidirectional Data Flow pattern.

[More info here](#setting-the-environment-variable)

## Core Components

- **ViewFeature**: The heart of `SwiftUIApp`, this protocol (with its extensions) is meant for `SwiftUI` 
implementations only and should be used to represent a Root UI Feature (Screen). 
The main goal of this protocol is 
  - Enable building a native SwiftUI View using Unidirectional Data Flow
  - Reduce the dependency injection footprint by leveraging native SwiftUI `Environment` and `EnvironmentObject`.
  - Splitting the `View` implementation in two different files `ViewFeature` conformance, for business logic, and `View` extension conformance so to build the body representation of the feature.
  - Possibility to opt-In for full Unit Testing support for your `ViewFeature` in `Debug` builds.
- **ViewModelFeature**: This protocol offers the same guardrails as `ViewFeature` but is mainly meant to be adopted 
for UIKit implementations but also with `SwiftUI`. If you prefer the `ViewModel` and you want to use with SwiftUI 
mind that you are fully responsible of the ViewModel injection into the View and most importantly you are also 
responsible for all the dependency injection of the ViewModel itself since SwiftUI `Environment` and 
`EnvironmentObject` cannot be used in this case. 
- **Test Support**: Code meant to enable `SwiftUI` being Unit Testing friendly. These implementations are opt-in and 
only available for `Debug` builds. This is made on purpose to avoid any sort of unintentional alteration of the native 
`SwiftUI` implementations when creating a Release build.

[Checkout here the full documentation](https://falcon283.github.io/SwiftUIApp/documentation/swiftuiapp)

---

## SwiftUIApp Test Support and SPM

SPM (Swift Package Manager) simplifies dependency management, but it has limitations regarding build settings. 
We can overcomes these constraints by leveraging environment variables to toggle `Test Support` for `Debug` builds 
only. Follow these steps to configure your system or your CI:

### Setting the Environment Variable

1. Edit your shell configuration file (`~/.zprofile` or `~/.bash_profile`) and add:
   ```bash
   export SWIFTUIAPP_TEST_SUPPORT=TRUE
   ```
2. Open a new terminal window and verify the variable is set:
   ```bash
   echo $SWIFTUIAPP_TEST_SUPPORT
   env | grep SWIFTUIAPP_TEST_SUPPORT
   ```

### Behavior Based on XCode Launch Method

- **Start Xcode via Terminal**: Launch your project with `xed .` from the terminal, and Xcode will inherit the environment variables, enabling `Test Support` in the `SwiftUIApp` package.
- **Start Xcode via Dock or Spotlight**: The environment variable will not be available, and the `Test Support` code will be excluded.

This setup supports two key use cases:
1. **Development and Testing**: Enable `Test Support` for writing and debugging unit tests.
2. **Production Readiness**: Exclude `Test Support` for regular builds, ensuring the app uses SwiftUI without modifications.

### Debug vs. Release Builds

- `Test Support` is only enabled for `Debug` builds if the `SWIFTUIAPP_TEST_SUPPORT` variable is set.
- `Test Support` is **never** included in `Release` builds.

---

### Github Actions

The following actions are available on the repository:
1. `Swift`: Allows Build and Tests for all the available platforms and configurations automatically.
2. `SwiftUIApp DocC`: Allows building and deploying the DocC documentation as Github Page.

Mind: `Swift` actions are triggered automatically only after a push on the `develop` branch to limit the execution time. 
If needed the `Swift` action can be executed on demand on PR basis if it gets labeled with `Run Builds` or `Run Tests`.

`SwiftUIApp DocC` documentation deploy is instead triggered automatically on every `develop` branch push.

You can also install some helpers to do some try out locally

#### Act
- Install act using `brew install act`
- On terminal run `act`. It runs the default setup provided by `.actrc` available in the repo which build and test all the variants.

---

## Conclusion

`SwiftUIApp` provides an extremely lightweight foundation for building scalable, testable SwiftUI apps using the tools SwiftUI already offers. It enables developers to integrate testability into their architecture without deviating from standard SwiftUI practices.

Feel free to explore the library, adapt it to your needs, or use it as a stepping stone for your custom architecture. Happy coding!

## Articles

Do you want to know more about this project? Check out my related articles:

### Unit Testing

- [Making SwiftUI Testable 1/5 - Introduction](https://medium.com/@gabrynet83/making-swiftui-testable-1-5-introduction-a8c6b1fb5968)
- [Making SwiftUI Testable 2/5 - State](https://medium.com/@gabrynet83/making-swiftui-testable-2-5-db296e061dc9)
- [Making SwiftUI Testable 3/5 - Environment](https://medium.com/@gabrynet83/making-swiftui-testable-3-5-environment-ba84e1a0cf5d)
- [Making SwiftUI Testable 4/5 - Storage](https://medium.com/@gabrynet83/making-swiftui-testable-4-5-storage-6e9f38c1f15a)
- [Making SwiftUI Testable 5/5 - CoreData](https://medium.com/@gabrynet83/making-swiftui-testable-5-5-coredata-8ab075fce1d2)

### ViewFeature

- [SwiftUI + ViewFeature 1/3 - Unidirectional Data Flow](https://medium.com/@gabrynet83/swiftui-viewfeature-1-3-unidirectional-data-flow-a59fcbfd2151)
- [SwiftUI + ViewFeature 2/3 - Task Cancellation](https://medium.com/@gabrynet83/swiftui-viewfeature-2-3-task-cancellation-0e93bd91379f)
- [SwiftUI + ViewFeature 3/3 - SwiftUIApp SPM](https://medium.com/@gabrynet83/swiftui-viewfeature-3-3-swiftuiapp-spm-7d0a51aa55ec)
