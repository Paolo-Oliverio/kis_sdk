# tests/test_discovery/test_platform_overrides.cmake
include("${CMAKE_CURRENT_LIST_DIR}/../test_utilities.cmake")
include(discovery)
include(file_utils) # for kis_get_package_name_from_path

# --- Test Setup ---
setup_test_env(temp_dir)
file(COPY "${TEST_FIXTURES_DIR}/discovery_test_basic/" DESTINATION "${temp_dir}")
set(CMAKE_CURRENT_SOURCE_DIR "${temp_dir}/discovery_test_basic") # Mock the project root

# --- Define Inputs for the function ---
set(KIS_PLATFORM "windows")
set(KIS_PLATFORM_TAGS "desktop;windows") # Must match platform_setup.cmake logic

# --- Call the function under test ---
discover_and_map_packages(
    out_paths
    out_override_keys
    out_override_values
)

# --- Assertions ---
list(LENGTH out_paths path_count)
assert_equal(${path_count} 2) # Should find both packages

assert_equal("${out_override_keys}" "common_pkg_A")
assert_equal("${out_override_values}" "win_pkg_B")

message(STATUS "PASS: discover_and_map_packages (platform override)")