# CMakeLists.txt

cmake_minimum_required(VERSION 3.20)

# --- 1. Perform All Generic Package Setup ---
include(cmake/package_setup.cmake)

# --- 2. Load Package-Specific Manifest ---
include(kis.package.cmake)
project(${PACKAGE_NAME} VERSION ${PACKAGE_VERSION})

# --- 3. Define Library Target ---
{% if cookiecutter.library_type == 'Library' -%}
# A regular library has source files.
add_library(${PACKAGE_NAME} main/src/${PACKAGE_NAME}.cpp)
{% else -%}
# An INTERFACE library is header-only and has no source files.
add_library(${PACKAGE_NAME} INTERFACE)
{% endif -%}
add_library(kis::${PACKAGE_NAME} ALIAS ${PACKAGE_NAME})

target_include_directories(${PACKAGE_NAME} 
{%- if cookiecutter.library_type == 'Library' %} PUBLIC{% else %} INTERFACE{% endif %}
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/main/include>
    $<INSTALL_INTERFACE:include>
)

# --- 4. Apply Compiler Presets (Universal) ---
if(BUILDING_WITH_SUPERBUILD)
    kis_apply_sdk_build_settings_to_target(${PACKAGE_NAME})
else()
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
{% if cookiecutter.library_type == 'Library' -%}
kis_install_package()
{% else -%}
kis_install_interface_package()
{% endif -%}

# --- 8. Add Optional Components ---
if(KIS_BUILD_TESTS OR KIS_BUILD_SAMPLES OR KIS_BUILD_BENCHMARKS)
    enable_testing()
    add_subdirectory(secondary)
endif()