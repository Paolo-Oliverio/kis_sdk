# CMakeLists.txt (Root Superbuild)

cmake_minimum_required(VERSION 3.20)

# This hook ensures that environment setup (like dependency cache paths) happens
# before the project() command is even called.
set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/kis_build_system/modules/env_setup.cmake")

project(kis_sdk)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_INSTALL_MESSAGE LAZY)
include(CTest)

# --- 1. Load Build System & Configure SDK ---

# STEP 1.1: Make the build system modules findable.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/kis_build_system/modules")

# STEP 1.2: Include the modules needed for initial setup.
# Load kis_build_system first to get tag_system available
include(kis_build_system)
include(platform_setup)
include(paths) # Contains setup_sdk_paths()
include(build_summary) # For configuration summary at end
include(manifest_validation) # For validating package manifests
include(warning_summary) # For collecting and displaying warnings
include(compiler_cache) # For auto-detecting ccache/sccache
include(dependency_graph) # For dependency graph visualization
include(build_profiling) # For build time profiling
include(file_utils) # For unified file globbing utilities
include(cache_validation) # For cache staleness detection
include(incremental_validation) # For smart package validation
include(incremental_dependencies) # For smart dependency fetching

# STEP 1.3: Set up the install paths (e.g., CMAKE_INSTALL_PREFIX, platform-specific dirs).
setup_sdk_paths()

# STEP 1.4: Initialize build profiling and validation stats (if enabled)
kis_profile_init()
kis_init_validation_stats()

# STEP 1.5: Enable compiler cache if available (faster rebuilds)
kis_setup_compiler_cache()

# STEP 1.6: Now include the rest of the SDK config.
include(sdk_options)
include(sdk_presets)
include(sdk_versions)
include(parallel_fetch) # For parallel dependency fetching (needs KIS_PARALLEL_FETCH_WORKERS from sdk_options)

# STEP 1.7: Validate environment and check for cache issues
if(KIS_DIAGNOSTIC_MODE)
    kis_dump_cache_variables()
    kis_report_cache_size()
endif()
kis_check_cache_staleness()
kis_validate_environment()

# STEP 1.6: Add the build system as a sub-project so its own installation
# logic is configured. This is separate from including its modules.
add_subdirectory(kis_build_system)

# --- 2. Initialize Superbuild State ---

# This flag is used by modules to switch between superbuild and standalone behavior.
set(BUILDING_WITH_SUPERBUILD TRUE CACHE INTERNAL "Flag for internal modules")

# Initialize the dependency override system.
set(KIS_DEPENDENCY_OVERRIDES "" CACHE STRING "List of 'original;override' pairs.")
_kis_get_override_map()
set(base_override_keys ${map_keys})
set(base_override_values ${map_values})

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

# --- 3. Discover, Configure, Populate, and Link Packages ---

if(KIS_SDK_RESOLVE_PACKAGES)
    kis_resolve_and_sync_packages()
endif()

message(STATUS "\n--- PHASE 1: PRE-SCAN FOR CUSTOM VARIANTS ---")
# First pass: discover all custom variants before any package configuration
kis_prescan_custom_variants()

message(STATUS "\n--- PHASE 2: DISCOVERING AND CONFIGURING PACKAGES ---")
set(SDK_PACKAGES "")
discover_and_map_packages(SDK_PACKAGES platform_override_keys platform_override_values)

# Combine platform-based overrides with user-defined overrides
list(APPEND platform_override_keys ${base_override_keys})
list(APPEND platform_override_values ${base_override_values})
set_property(GLOBAL PROPERTY KIS_OVERRIDE_MAP_KEYS ${platform_override_keys})
set_property(GLOBAL PROPERTY KIS_OVERRIDE_MAP_VALUES ${platform_override_values})

configure_discovered_packages(${SDK_PACKAGES})

message(STATUS "\n--- PHASE 3: POPULATING THIRD-PARTY DEPENDENCIES ---")
kis_populate_declared_dependencies()

message(STATUS "\n--- PHASE 4: LINKING ALL PACKAGE DEPENDENCIES ---")
link_all_package_dependencies(${SDK_PACKAGES})

# --- 4. Configure Installation for Third-Party Dependencies ---
message(STATUS "\n--- PHASE 5: CONFIGURING THIRD-PARTY DEPENDENCY INSTALLATION ---")
kis_install_third_party_dependencies()

# --- 5. Generate Top-Level SDK Configuration ---
message(STATUS "\n--- PHASE 6: GENERATING TOP-LEVEL SDK INSTALLATION ---")
generate_sdk_config_file()

# --- 6. Print Build Summary ---
message(STATUS "")
kis_print_build_summary(${SDK_PACKAGES})
message(STATUS "")

if(KIS_DIAGNOSTIC_MODE)
    kis_print_dependency_summary()
endif()

# --- 7. Print Warning Summary ---
kis_print_warning_summary()

# --- 8. Export Dependency Graph (if requested) ---
kis_export_dependency_graph()

# --- 9. Display Build Profile (if enabled) ---
kis_profile_report()

# --- 10. Display Incremental Validation Stats (if enabled) ---
kis_report_validation_stats()

# Add the tests directory, but only if building the top-level project.
# Exclude from 'all' to avoid adding it during normal builds.
if(PROJECT_IS_TOP_LEVEL)
    option(KIS_BUILD_SYSTEM_TESTS "Build the tests for the build system itself" ON)
    if(KIS_BUILD_SYSTEM_TESTS)
        add_subdirectory(tests EXCLUDE_FROM_ALL)
    endif()
endif()