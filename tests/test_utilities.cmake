# tests/test_utilities.cmake

# Set the root of the build system so tests can find it
set(KIS_BUILD_SYSTEM_ROOT "${CMAKE_CURRENT_LIST_DIR}/../kis_build_system")
list(APPEND CMAKE_MODULE_PATH "${KIS_BUILD_SYSTEM_ROOT}/modules")

# --- Assertion Library ---
function(assert_equal A B)
    if(NOT "${A}" STREQUAL "${B}")
        message(FATAL_ERROR "Assertion failed: '${A}' does not equal '${B}'")
    endif()
endfunction()

function(assert_true CONDITION)
    if(NOT ${CONDITION})
        message(FATAL_ERROR "Assertion failed: Condition is not true.")
    endif()
endfunction()

function(assert_defined VAR)
    if(NOT DEFINED ${VAR})
        message(FATAL_ERROR "Assertion failed: Variable '${VAR}' is not defined.")
    endif()
endfunction()

# --- Fixture Management ---
set(TEST_FIXTURES_DIR "${CMAKE_CURRENT_LIST_DIR}/fixtures")

# Function to create a temporary, clean test directory
function(setup_test_env out_temp_dir)
    set(temp_dir "${CMAKE_BINARY_DIR}/temp_test_${CMAKE_JOB_ID}")
    file(REMOVE_RECURSE "${temp_dir}")
    file(MAKE_DIRECTORY "${temp_dir}")
    set(${out_temp_dir} "${temp_dir}" PARENT_SCOPE)
endfunction()