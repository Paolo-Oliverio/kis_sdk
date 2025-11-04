# This is the standard template for a KIS SDK package.
# It follows the modern, manifest-driven approach.

cmake_minimum_required(VERSION 3.20)
project({{cookiecutter.package_name}})

# --- 1. Bootstrap the Build System (for Standalone Builds) ---
# This block is the key to making a package self-contained. It's ignored
# when the package is built as part of the SDK superbuild.
if(CMAKE_PROJECT_IS_TOP_LEVEL)
    include(cmake/build_system_bootstrap.cmake)
endif()


# ==============================================================================
#           PACKAGE DEFINITION
# ==============================================================================
# The build system uses the `kis.package.json` manifest as the single source
# of truth for what this package is and what it needs.

{% if cookiecutter.library_type == "Library" %}
# --- Configuration for a standard compiled library ---

# This single command reads the manifest to determine the package name and type,
# creates the library target, applies all standard build settings, and
# automatically links dependencies declared for the "main" scope.
kis_define_package(
    SOURCES
        main/src/kis_{{cookiecutter.package_name}}.cpp
)

{% elif cookiecutter.library_type == "Interface" %}
# --- Configuration for a header-only INTERFACE library ---

# This command reads the manifest, creates an INTERFACE target, and applies
# all standard settings and "main" scope dependencies.
# No SOURCES are needed for an interface library.
kis_define_package()

{% elif cookiecutter.library_type == "Executable" %}
# --- Configuration for an EXECUTABLE application ---

# This command reads the manifest, creates an EXECUTABLE target, applies all
# standard build settings, and links "main" scope dependencies.
kis_define_package(
    SOURCES
        main/src/main.cpp
)

{% endif %}

# ==============================================================================
#           OPTIONAL COMPONENTS (Tests, Samples, etc.)
# ==============================================================================
# The build system automatically enables/disables these based on the
# KIS_BUILD_TESTS, KIS_BUILD_SAMPLES, etc. flags.

# Add a test executable.
# The build system will automatically find and link any dependencies from the
# manifest that are scoped for "tests" (e.g., doctest).
if(${KIS_BUILD_TESTS} OR ${KIS_BUILD_SAMPLES} OR ${KIS_BUILD_BENCHMARKS})
    add_subdirectory(secondary)
endif()
# End of CMakeLists.txt