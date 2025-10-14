# kis_packages/kis_basic_library/CMakeLists.txt

cmake_minimum_required(VERSION 3.20)

# --- 1. Perform All Generic Package Setup ---
include(cmake/package_setup.cmake)

# --- 2. Load Package-Specific Manifest ---
include(kis.package.cmake)
project(${PACKAGE_NAME} VERSION ${PACKAGE_VERSION})

# --- 3. Define Library Target ---
add_library(${PACKAGE_NAME} main/src/${PACKAGE_NAME}.cpp)
add_library(kis::${PACKAGE_NAME} ALIAS ${PACKAGE_NAME})

target_include_directories(${PACKAGE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/main/include>
    $<INSTALL_INTERFACE:include>
)

# --- 4. Apply Compiler Presets (Universal and Definitive Fix) ---
if(BUILDING_WITH_SUPERBUILD)
    # --- THIS IS THE FIX ---
    # Instead of creating a link dependency that confuses the install() command,
    # we call a helper function that directly copies the build settings.
    # This creates no link and therefore no export dependency.
    kis_apply_sdk_build_settings_to_target(${PACKAGE_NAME})
else()
    # In a standalone build, we apply the preset logic directly to our own target.
    message(STATUS "Applying standalone presets directly to ${PACKAGE_NAME}.")
    apply_kis_build_presets(${PACKAGE_NAME})
endif()

# --- 5. Handle Third-Party Dependencies ---
# Example: kis_handle_dependency(doctest GIT_REPOSITORY ... GIT_TAG ...)

# --- 6. Define Phase 2 Linking Logic ---
function(${PACKAGE_NAME}_link_dependencies)
    # target_link_libraries(${PACKAGE_NAME} PUBLIC fmt::fmt)
endfunction()

if(NOT BUILDING_WITH_SUPERBUILD)
    cmake_language(CALL ${PACKAGE_NAME}_link_dependencies)
endif()

# --- 7. Install the Package (Universal) ---
kis_install_package()

# --- 8. Add Optional Components ---
if(KIS_BUILD_TESTS OR KIS_BUILD_SAMPLES OR KIS_BUILD_BENCHMARKS)
    enable_testing()
    add_subdirectory(secondary)
endif()