# CMakeLists.txt (Root Superbuild)

cmake_minimum_required(VERSION 3.20)

set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/kis_build_system/modules/env_setup.cmake")

project(kis_sdk)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_INSTALL_MESSAGE LAZY)
include(CTest)

# --- 1. Load Build System & Configure SDK ---

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/kis_build_system/modules")

include(kis_state)
include(kis_build_system)
include(platform_setup)
include(paths)
include(build_summary)
include(diagnostics)
include(compiler_cache)
include(dependency_graph)
include(build_profiling)
include(file_utils)
include(incremental_validation)
include(incremental_dependencies)

kis_state_init()
setup_sdk_paths()
kis_profile_init()
kis_init_validation_stats()
kis_setup_compiler_cache()

include(sdk_options)
include(sdk_presets)
include(parallel_fetch)

if(KIS_DIAGNOSTIC_MODE)
    kis_dump_cache_variables()
endif()
kis_check_cache_staleness()
kis_validate_environment()

add_subdirectory(kis_build_system)

# --- 2. Initialize Superbuild State ---

set(BUILDING_WITH_SUPERBUILD TRUE CACHE INTERNAL "Flag for internal modules")

# User-defined overrides are handled separately before discovery
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

# --- 4. Discover, Configure, Populate, and Link Packages ---

if(KIS_SDK_RESOLVE_PACKAGES)
    kis_resolve_and_sync_packages()
endif()

message(STATUS "\n--- PHASE 1: PRE-SCAN FOR CUSTOM VARIANTS ---")
kis_prescan_custom_variants()

message(STATUS "\n--- PHASE 2: DISCOVERING AND CONFIGURING PACKAGES ---")
# Simplified call: No more output variables to manage. Results are in the state module.
discover_and_map_packages()

# Combine platform overrides (from state) with user overrides (from cache)
kis_state_get_override_map(platform_override_keys platform_override_values)
list(APPEND platform_override_keys ${base_override_keys})
list(APPEND platform_override_values ${base_override_values})
# Write the final, combined map back to the state for other modules to use
kis_state_set_override_map("${platform_override_keys}" "${platform_override_values}")

# Get the list of packages from the state for the next steps
kis_state_get_all_package_paths(SDK_PACKAGES)

configure_discovered_packages(${SDK_PACKAGES})

message(STATUS "\n--- PHASE 3: POPULATING THIRD-PARTY DEPENDENCIES ---")
kis_populate_declared_dependencies()

message(STATUS "\n--- PHASE 4: LINKING ALL PACKAGE DEPENDENCIES ---")
link_all_package_dependencies(${SDK_PACKAGES})

message(STATUS "\n--- PHASE 5: CONFIGURING THIRD-PARTY DEPENDENCY INSTALLATION ---")
kis_install_third_party_dependencies()

message(STATUS "\n--- PHASE 6: GENERATING TOP-LEVEL SDK INSTALLATION ---")
generate_sdk_config_file()

# --- 5. Reporting ---
message(STATUS "")
kis_print_build_summary(${SDK_PACKAGES})
message(STATUS "")

if(KIS_DIAGNOSTIC_MODE)
    kis_print_dependency_summary()
endif()

kis_print_warning_summary()
kis_export_dependency_graph()
kis_profile_report()
kis_report_validation_stats()

# --- 6. Build System Introspection Target ---
add_custom_target(kis_sdk_info
    COMMAND ${CMAKE_COMMAND} -E echo "Run 'cmake --build . --target help' for available targets."
    COMMENT "Displays a summary of the configured build system state."
    VERBATIM
)

if(PROJECT_IS_TOP_LEVEL)
    option(KIS_BUILD_SYSTEM_TESTS "Build the tests for the build system itself" ON)
    if(KIS_BUILD_SYSTEM_TESTS)
        add_subdirectory(tests EXCLUDE_FROM_ALL)
    endif()
endif()