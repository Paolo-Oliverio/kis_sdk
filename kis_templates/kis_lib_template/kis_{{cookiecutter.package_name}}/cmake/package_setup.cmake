# kis_packages/kis_basic_library/cmake/package_setup.cmake

# This file contains all the boilerplate for setting up a kis_ package.
# It should be the very first thing included in a package's CMakeLists.txt.

# --- 1. Find-or-Fetch the KIS Build System (Standalone Mode Only) ---
if(NOT BUILDING_WITH_SUPERBUILD)
    # This block only runs when this package is the top-level project.
    # It is responsible for acquiring the tools needed to build itself.

    # First, try to find a pre-installed build system. This works if the
    # user has previously built and installed the full kis_sdk.
    find_package(kis_build_system 0.1.0 QUIET)

    if(NOT kis_build_system_FOUND)
        # If not found, fetch it from its canonical Git repository.
        # This makes the project buildable with just a 'git clone'.
        message(STATUS "kis_build_system not found. Fetching from source...")
        include(FetchContent)
        FetchContent_Declare(
            kis_build_system
            # IMPORTANT: Replace with the actual URL of your build system repo
            GIT_REPOSITORY https://github.com/Paolo-Oliverio/kis_build_system.git
            #GIT_TAG        v0.1.0 # Or main, develop, etc.
        )
        FetchContent_MakeAvailable(kis_build_system)
        # After fetching the content, we must explicitly include the master
        # module file. This is what makes all the kis_* and apply_* functions
        # available to the rest of the build script. The find_package() route
        # does this automatically via its config file.
        include(${kis_build_system_SOURCE_DIR}/modules/kis_build_system.cmake)
    else()
        message(STATUS "Found and using pre-installed kis_build_system.")
    endif()

    # --- 2. Define Standalone Build Options ---
    # These options are only relevant when building this package by itself.
    # In a superbuild, the top-level SDK options take precedence.
    option(KIS_BUILD_TESTS "Build test projects." ON)
    option(KIS_BUILD_SAMPLES "Build sample projects." ON)
    option(KIS_BUILD_BENCHMARKS "Build benchmark projects." OFF)
    option(KIS_USE_PREBUILT_DEPS "Find dependencies in CMAKE_PREFIX_PATH instead of fetching them." OFF)
endif()

# From this point on, all kis_* functions (kis_install_package, kis_add_test, etc.)
# and build options (KIS_BUILD_TESTS, etc.) are guaranteed to exist.