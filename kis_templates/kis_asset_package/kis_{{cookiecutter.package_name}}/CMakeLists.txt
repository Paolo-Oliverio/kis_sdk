# kis_packages/kis_{{cookiecutter.package_name}}/CMakeLists.txt (Asset Package Template)

cmake_minimum_required(VERSION 3.20)

# --- 1. Perform All Generic Package Setup ---
include(cmake/package_setup.cmake)

# --- 2. Load Package-Specific Manifest ---
include(kis.package.cmake)
project(${PACKAGE_NAME} VERSION ${PACKAGE_VERSION})

# --- 3. Define a Target for Dependency Management ---
# We create an INTERFACE target so that other packages can 'find_package'
# and 'target_link_libraries' against this asset pack, creating a clear
# dependency graph. It produces no binary artifact.
add_library(${PACKAGE_NAME} INTERFACE)
add_library(kis::${PACKAGE_NAME} ALIAS ${PACKAGE_NAME})

# --- 4. Install Assets ---
# This is the primary purpose of this package. It calls the special
# asset installation function from the build system.
kis_install_assets()

# --- 5. Install the Package Configuration ---
# This makes the package findable via find_package(). We use the interface
# version since there are no library binaries to install.
kis_install_interface_package()

# --- 6. Add Optional Components (Tests) --- asset may require custom tests.
# It's good practice to have tests, even for assets (e.g., to check for
# their existence or parse metadata).
#if(KIS_BUILD_TESTS)
#    enable_testing()
#    add_subdirectory(secondary)
#endif()