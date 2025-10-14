# KIS SDK (Keep It Simple SDK)

[![License](https://img.shields.io/badge/license-MIT-blue)](./LICENSE)

The KIS SDK is a collection of C++ libraries and a powerful, modern CMake-based build system designed for creating scalable, cross-platform applications. It emphasizes modularity, ease of use, and a consistent development experience.

The core philosophy is to provide a "superbuild" for developing all SDK packages together, while ensuring every individual package can be built, tested, and consumed standalone.

This SDK focuses on making low-code project setups in CMake, so users don't have to know all the quirks and tricks of CMake. It abstracts away the complexity, allowing you to get started quickly with advanced C++ project setups without deep CMake expertise.

### Key Features

*   **Unified Build System**: A central set of CMake scripts provides consistent functions for packaging, installation, and dependency management.
*   **Standalone Package Builds**: Every package within the SDK can be cloned and built on its own (even without kis_sdk), automatically fetching only necessary dependencies (e.g. kis_build_system).
*   **Third-Party Dependency Management**: Uses CMake's `FetchContent` for robust, version-controlled dependency handling with a persistent cache.
*   **First-Party Package Resolution**: Automatically discovers and clones missing internal SDK packages from trusted Git repositories.
*   **Consistent Tooling**: Standardized functions for adding tests, samples, and benchmarks across all packages.
*   **Modern CMake Practices**: Produces relocatable, exportable CMake packages for easy consumption by other projects.
*   **Project Kickstarting**: Uses `cookiecutter` templates to quickly scaffold new packages, eliminating boilerplate.

---

## Getting Started

### Prerequisites

*   **CMake**: Version 3.20 or higher.
*   **C++ Compiler**: A C++17 compliant compiler (GCC, Clang, MSVC).
*   **Git**: For cloning the repository and managing dependencies.
*   **Ninja** (Recommended): For faster builds. (shipped preset defaults to it)
*   **Python & Cookiecutter** (Optional): For using the project creation templates.
    ```bash
    pip install cookiecutter
    ```
*   **Visual Studio Code** with **Cmake Extension** (Recommended) any other ide compatible with cmake will do.

### Installation & Usage

There are two primary ways to use the KIS SDK: as an SDK developer contributing to the packages, or as a consumer using the installed SDK in your own application.

#### 1. For SDK Developers (Superbuild)

This is the standard workflow for working on the SDK packages themselves.

```bash
# 1. Clone the repository with its submodules
git clone --recurse-submodules https://github.com/Paolo-Oliverio/kis_sdk.git
cd kis_sdk
```
Project is intended and tested on Visual Studio Code with the CMake Tools extension.In vscode you can build and install Debug and Release version of the sdk.

#### 2. For Consumers of the SDK

Once the SDK has been built and installed, you can use its packages in your own external projects.

A sample project will show how to find sdk and start using packages as dependencies.

---

## Creating a New Package (with Cookiecutter)

To ensure consistency and reduce boilerplate, we use `cookiecutter` templates to create new packages.

### Manual Usage

From the root of the SDK, run the following command:
```bash
cookiecutter kis_templates/kis_lib_template -o kis_packages
```
This will prompt you for the package name, version, and description, and then generate a complete, ready-to-build package inside the `kis_packages` directory.

### Visual Studio Code Integration

select `Kickstart: Create New Library Package` task in visual studio.
then in terminal choose a name for the package (kis_ will be added).
this creates a library with a totally working cmake file to modify and expand.
