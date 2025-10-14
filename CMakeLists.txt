# CMakeLists.txt (Root Superbuild)

cmake_minimum_required(VERSION 3.20)

set(KIS_BUILD_SYSTEM_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/kis_build_system")
set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES "${KIS_BUILD_SYSTEM_ROOT}/cmake/build_system/env_setup.cmake")

project(kis_sdk)
enable_testing()
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# --- 1. Include Build System Modules ---
list(APPEND CMAKE_MODULE_PATH "${KIS_BUILD_SYSTEM_ROOT}/cmake/build_system")

include(paths)
include(discovery)
include(components)
include(dependencies)
include(dependency_resolution)
include(packaging)
include(installation) # ADDED: Make sure this is included with the others.

# --- 2. Load SDK Configuration ---
setup_sdk_paths()
include(sdk_options)
include(sdk_presets)
include(sdk_versions)

set(KIS_GENERIC_CONFIG_TEMPLATE "${KIS_BUILD_SYSTEM_ROOT}/cmake/templates/GenericPackageConfig.cmake.in")
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

# ==============================================================================
# PHASE 1: RESOLVE AND SYNC FIRST-PARTY PACKAGES
# ==============================================================================
if(KIS_SDK_RESOLVE_PACKAGES)
    message(STATUS "\n--- RESOLVING AND SYNCHRONIZING SDK PACKAGES ---")
    kis_resolve_and_sync_packages()
endif()

# ==============================================================================
# PHASE 2: DISCOVER AND CONFIGURE PACKAGES (REGISTRATION)
# ==============================================================================
message(STATUS "\n--- DISCOVERING AND CONFIGURING PACKAGES (REGISTRATION) ---")
set(SDK_PACKAGES "")
discover_packages("${CMAKE_CURRENT_SOURCE_DIR}/kis_packages" SDK_PACKAGES)
configure_discovered_packages(${SDK_PACKAGES})

# ==============================================================================
# PHASE 3: POPULATE THIRD-PARTY DEPENDENCIES
# ==============================================================================
message(STATUS "\n--- POPULATING ALL DECLARED THIRD-PARTY DEPENDENCIES ---")
kis_populate_declared_dependencies()

# ==============================================================================
# PHASE 4: LINK DEPENDENCIES
# ==============================================================================
message(STATUS "\n--- LINKING ALL PACKAGE DEPENDENCIES ---")
link_all_package_dependencies(${SDK_PACKAGES})

# ==============================================================================
# PHASE 5: CONFIGURE FINAL INSTALLATION
# ==============================================================================
message(STATUS "\n--- CONFIGURING SDK INSTALLATION ---")
# This call now works because we included the 'installation' module at the top.
generate_sdk_config_file()