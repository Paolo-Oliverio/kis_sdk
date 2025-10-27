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
kis_define_package()