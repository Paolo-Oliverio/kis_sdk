# CMakeLists.txt (Root Superbuild)

cmake_minimum_required(VERSION 3.22)

set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/kis_build_system/modules/env_setup.cmake")

project(kis_sdk)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_INSTALL_MESSAGE LAZY)
#include(CTest)

# --- 1. Load Build System & Configure SDK ---

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/kis_build_system/modules")

# Load the CORE build engine.
include(kis_build_system)

# Load SUPERBUILD-SPECIFIC modules.
include(platform_setup)
include(dependency_resolution)

# Initialize state and load SDK options
kis_state_init()
setup_sdk_paths()
kis_init_validation_stats()
kis_setup_compiler_cache()
include(sdk_options)
include(sdk_presets)
kis_profile_init()

if(KIS_DIAGNOSTIC_MODE)
    kis_dump_cache_variables()
endif()
kis_check_cache_staleness()
kis_validate_environment()

# --- 2. Initialize Superbuild State ---

set(BUILDING_WITH_SUPERBUILD TRUE CACHE INTERNAL "Flag for internal modules")

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

# Add the build system itself (after KIS_BUILD_TESTS is defined)
add_subdirectory(kis_build_system)

# --- 4. Discover, Configure, Populate, and Link Packages ---

if(KIS_SDK_RESOLVE_PACKAGES)
    kis_resolve_and_sync_packages()
endif()

message(STATUS "\n--- PHASE 1: PRE-SCAN FOR CUSTOM VARIANTS ---")
kis_prescan_custom_variants()

message(STATUS "\n--- PHASE 2: DISCOVERING AND CONFIGURING PACKAGES ---")
discover_and_map_packages()
kis_state_get_all_package_paths(SDK_PACKAGES)
configure_discovered_packages(${SDK_PACKAGES})

message(STATUS "\n--- PHASE 3: POPULATING THIRD-PARTY DEPENDENCIES ---")
kis_populate_declared_dependencies()

message(STATUS "\n--- PHASE 4: LINKING ALL PACKAGE DEPENDENCIES ---")

# Step 4a: Resolve ALL deferred links from ALL targets (packages, tests, etc.) at once.
kis_resolve_and_correct_all_links()

# Step 4b: Execute the corrected link commands for each target that requested them.
kis_state_get_deferred_link_targets(targets_to_link)
foreach(target_name ${targets_to_link})
    if(TARGET ${target_name})
        kis_execute_deferred_links(${target_name})
    else()
        kis_message_verbose("Skipping links for '${target_name}' (target was not created, likely skipped)")
    endif()
endforeach()

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