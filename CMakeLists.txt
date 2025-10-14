# CMakeLists.txt (Root Superbuild) - FINAL

cmake_minimum_required(VERSION 3.20)

# Use an absolute path for CMAKE_PROJECT_TOP_LEVEL_INCLUDES.
set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/kis_build_system/modules/env_setup.cmake")

project(kis_sdk)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_INSTALL_MESSAGE LAZY)

# --- 1. Load the Build System Package ---
# First, add the directory. This runs its CMakeLists.txt for installation setup.
add_subdirectory(kis_build_system)

# Second, explicitly include the master module using an ABSOLUTE PATH.
# This makes all the kis_* functions available to this script.
include(${CMAKE_CURRENT_SOURCE_DIR}/kis_build_system/modules/kis_build_system.cmake)

# --- 2. Configure SDK ---
# All these functions are now defined and available from step 1.
setup_sdk_paths()
include(sdk_options)
include(sdk_presets)
include(sdk_versions)

# NEW: Define the path to the generic config template for the packaging module to use.
set(KIS_GENERIC_CONFIG_TEMPLATE "${CMAKE_CURRENT_SOURCE_DIR}/kis_build_system/templates/GenericPackageConfig.cmake.in")
set(BUILDING_WITH_SUPERBUILD TRUE CACHE INTERNAL "Flag to indicate a superbuild context")

# --- 3. Define Meta-Targets ---
if(KIS_BUILD_TESTS)
  enable_testing()
  add_custom_target(all_tests)
endif()
if(KIS_BUILD_SAMPLES)
  add_custom_target(all_samples)
endif()
if(KIS_BUILD_BENCHMARKS)
  add_custom_target(all_benchmarks)
endif()

# --- 4. Discover and Configure Packages ---
if(KIS_SDK_RESOLVE_PACKAGES)
    message(STATUS "\n--- RESOLVING AND SYNCHRONIZING SDK PACKAGES ---")
    kis_resolve_and_sync_packages()
endif()

message(STATUS "\n--- DISCOVERING AND CONFIGURING PACKAGES (REGISTRATION) ---")
set(SDK_PACKAGES "")
discover_packages("${CMAKE_CURRENT_SOURCE_DIR}/kis_packages" SDK_PACKAGES)
configure_discovered_packages(${SDK_PACKAGES})

message(STATUS "\n--- POPULATING ALL DECLARED THIRD-PARTY DEPENDENCIES ---")
kis_populate_declared_dependencies()

message(STATUS "\n--- LINKING ALL PACKAGE DEPENDENCIES ---")
link_all_package_dependencies(${SDK_PACKAGES})

message(STATUS "\n--- CONFIGURING SDK INSTALLATION ---")
generate_sdk_config_file()