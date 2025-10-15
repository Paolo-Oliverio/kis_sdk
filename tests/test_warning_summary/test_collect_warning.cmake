# tests/test_warning_summary/test_collect_warning.cmake

include("${CMAKE_CURRENT_LIST_DIR}/../test_utilities.cmake")
include(warning_summary)

message(STATUS "Running test: kis_collect_warning")

# Test 1: Collect a single warning
kis_collect_warning("This is a test warning")
get_property(count GLOBAL PROPERTY KIS_BUILD_WARNINGS_COUNT)
assert_equal(${count} 1)

get_property(warnings GLOBAL PROPERTY KIS_BUILD_WARNINGS)
assert_equal("${warnings}" "This is a test warning")

message(STATUS "PASS: kis_collect_warning")