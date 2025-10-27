### **README for the `kis_sdk` (Main Project)**

# KIS SDK (Keep It Simple SDK)

[![License](https://img.shields.io/badge/license-MIT-blue)](./LICENSE.txt)

The KIS SDK is a collection of modern C++ libraries and a powerful, convention-over-configuration CMake build system designed for creating scalable, cross-platform applications. It emphasizes modularity, developer experience, and build consistency.

The core philosophy is to provide a comprehensive **superbuild** for developing all SDK packages together, while architecting every individual package to be **built, tested, and consumed standalone**.

This SDK abstracts away the complexity of modern CMake, enabling developers to create and maintain advanced C++ projects with a declarative, manifest-driven workflow and minimal boilerplate.

## Key Features

*   **Manifest-Driven Architecture**: Define your package's metadata, dependencies, build variants, and platform compatibility in a single `kis.package.json` file. The build system handles the rest.
*   **Dual-Mode Builds**: Develop in a unified "superbuild" environment or build any package individually for isolated testing. The build system automatically adapts.
*   **Advanced ABI-Aware Build Variants**: Go beyond "Debug/Release". Define custom, ABI-compatible variants like `profiling` or `asan`, with automatic artifact reuse from base variants to dramatically speed up multi-config workflows.

### Advanced Platform & Feature Control

*   **Platform-Specific Overrides**: Provide specialized source files, headers, or assets for different platforms (`windows`, `linux`) or platform groups (`desktop`, `mobile`, `posix`). The build system automatically selects the most specific implementation at compile time.
*   **Package Overrides**: Replace an entire core package with a platform-specific or custom implementation. For example, a package in `kis_packages/windows/` can completely replace a generic package of the same name, enabling deeply specialized backends.
*   **Feature-Based Filtering**: Associate packages with features like `tools`, `editor`, or `profiling`. The SDK will only configure and build packages whose features are active, keeping builds lean and focused.

### Precise & Automated Dependency Management

*   **Component Scoping**: Declare dependencies for `tests`, `samples`, or `benchmarks` only—they won't be linked against your main library.
*   **Auto-Discovery & Fetching**: The SDK automatically discovers missing internal packages and fetches all dependencies from trusted repositories, simplifying setup.
*   **Robust Integration**: Handle complex third-party libraries with mismatched target names (e.g., `glfw3` vs. `glfw`) declaratively in your manifest.

### Exceptional Developer Experience (DevEx)

*   **Effortless Scaffolding**: Integrated `cookiecutter` templates generate fully functional package skeletons in seconds.
*   **Blazing Fast Rebuilds**: Automatic detection of `ccache`/`sccache` and smart incremental configuration ensure near-instantaneous builds after small changes.
*   **Parallel Operations**: First-time setup is slashed by fetching all dependencies in parallel.
*   **Introspection & Debugging**: Generate dependency graphs and profile build times to understand and optimize your project's architecture.
*   **Modern CMake & Installability**: The build process produces properly versioned, relocatable, and exportable CMake packages, making them trivial to consume in downstream applications with `find_package()`.

---

## Getting Started

### Prerequisites

*   **CMake**: Version 3.20 or higher.
*   **C++ Compiler**: A C++20 compliant compiler (GCC, Clang, MSVC).
*   **Git**: For cloning the repository and managing dependencies.
*   **Ninja** (Recommended): For faster builds. Our presets default to it.
*   **Python & Cookiecutter** (Optional but Recommended): For using the project creation templates.
    ```bash
    pip install cookiecutter
    ```
*   **IDE**: Visual Studio Code with the [CMake Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools) extension is the recommended and tested environment.

### Developer Workflow (Superbuild)

This is the standard workflow for contributing to the SDK packages.

1.  **Clone the SDK.**
    ```bash
    git clone --recurse-submodules https://github.com/Paolo-Oliverio/kis_sdk.git
    cd kis_sdk
    ```

2.  **Configure and Build.**
    Open the folder in Visual Studio Code. The CMake Tools extension will prompt you to select a preset (e.g., `debug` or `release`). The project will configure automatically, fetching any required dependencies.

3.  **Build, Test, and Install.**
    Use the standard CMake or VS Code commands to build the `all` target, run tests via CTest (`ctest --preset debugTest`), or build the `install` target to populate the installation directory.

---

## The KIS Philosophy

The primary goal of this SDK is to **reduce friction** and **empower developers**.

*   **For Package Developers**: Focus on your C++ code, not on CMake boilerplate. Creating a new library, adding a test-only dependency, or providing a Windows-specific implementation should be a simple, declarative change in your `kis.package.json` or project structure.
*   **For SDK Consumers**: Using a KIS library should be as simple as adding `find_package(kis_core REQUIRED)` and `target_link_libraries(... kis::core)`. The generated CMake packages are robust, relocatable, and easy to integrate.

We achieve this by embedding modern best practices directly into the tooling, providing a guided and consistent experience for everyone.

## Creating a New Package (The Easy Way)

Never write a package from scratch! Use the integrated `cookiecutter` templates.

*   **From Visual Studio Code (Recommended)**:
    1.  Open the Command Palette (`Ctrl+Shift+P`).
    2.  Select `Tasks: Run Task`.
    3.  Choose one of the `kickstart` tasks (e.g., `kickstart a new kis_package library`).
    4.  Enter the name of your package at the prompt (e.g., `networking`).

This will generate a complete, ready-to-build package inside the `kis_packages` directory. The superbuild will automatically pick it up on the next configure run.

Supported templates include:
*   **Library**: Standard static library (shared library support in development).
*   **Interface**: Header-only library or a package for aggregating dependencies and settings.
*   **Executable**: A standalone executable application.
*   **Asset Only**: A package containing only assets, with no compiled code.

---

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.