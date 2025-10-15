# KIS SDK (Keep It Simple SDK)

[![License](https://img.shields.io/badge/license-MIT-blue)](./LICENSE.txt)

The KIS SDK is a collection of modern C++ libraries and a powerful, convention-over-configuration CMake build system designed for creating scalable, cross-platform applications. It emphasizes modularity, developer experience, and build consistency.

The core philosophy is to provide a comprehensive **superbuild** for developing all SDK packages together, while architecting every individual package to be **built, tested, and consumed standalone**.

This SDK abstracts away the complexity of modern CMake, enabling developers to create and maintain advanced C++ projects with minimal boilerplate and a "low-code" `CMakeLists.txt`.

### Key Features

*   **Dual-Mode Architecture**: Develop in a unified "superbuild" environment or build any package individually. The build system automatically adapts.
*   **Automated First-Party Dependencies**: The SDK automatically discovers missing internal packages (e.g., `kis_core_utils` needing `kis_platform`) and clones them from trusted repositories, simplifying setup.
*   **Robust Third-Party Dependencies**: Uses CMake's `FetchContent` with a persistent local cache (`_deps_cache`), ensuring fast, reproducible builds and consistent versions across the entire SDK.
*   **Effortless Project Scaffolding**: Integrated `cookiecutter` templates and VS Code tasks (`Kickstart a new package`) generate fully functional, best-practice package skeletons in seconds.
*   **Consistent & Opinionated Toolchain**: A central set of compiler presets (`sdk_presets.cmake`) enforces high standards (warning levels, C++ standard, defines) across all packages, ensuring everyone builds with the same rules (settings will be customizable in future versions).
*   **Modern CMake & Installability**: The build process produces properly versioned, relocatable, and exportable CMake packages, making them trivial to consume in downstream applications with `find_package()`.
*   **Advanced Dependency Overrides**: A powerful override system allows developers to swap out any dependency (e.g., `kis::core` with `my_mock_core`) for advanced testing or debugging scenarios.
*   **Intelligent Auto-Discovery**: Simply add a new package directory, and the superbuild automatically discovers and integrates it on the next configure run.

---

## Getting Started

### Prerequisites

*   **CMake**: Version 3.20 or higher.
*   **C++ Compiler**: A C++17 compliant compiler (GCC, Clang, MSVC).
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
    Open the folder in Visual Studio Code. The CMake Tools extension will prompt you to select a preset (e.g., `debug` or `release`). The project will configure automatically.

3.  **Build, Test, and Install.**
    Use the standard CMake or VS Code commands to build the `all` target, run tests via CTest (`ctest --preset debugTest`), or build the `install` target to populate the installation directory.

---

## The KIS Philosophy

The primary goal of this SDK and its build system is to **reduce friction**.

*   **For Package Developers**: Focus on your C++ code, not on CMake boilerplate. Creating a new library, adding tests, and handling dependencies should be a matter of a few declarative function calls.
*   **For SDK Consumers**: Using a KIS library should be as simple as adding `find_package(kis_core_utils REQUIRED)` and `target_link_libraries(... kis::core_utils)`. The build system handles the rest.

We achieve this by embedding modern best practices directly into the tooling, providing a guided and consistent experience for everyone.

## Creating a New Package (The Easy Way)

Never write a package from scratch! Use the integrated `cookiecutter` templates.

*   **From Visual Studio Code (Recommended)**:
    1.  Open the Command Palette (`Ctrl+Shift+P`).
    2.  Select `Tasks: Run Task`.
    3.  Choose one of the `kickstart` tasks (e.g., `kickstart a new kis_package library`).
    4.  Enter the name of your package at the prompt (e.g., `networking`).

Supported templates are:
* static library (shared library in the work)
* interface library (for header only libraries or for settings and dependency inheritance)
* asset only package (all package types can have assets this is for pure asset only use case)

This will generate a complete, ready-to-build package inside the `kis_packages` directory. The superbuild will automatically pick it up on configure.