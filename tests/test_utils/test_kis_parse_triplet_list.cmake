# tests/test_utils/test_kis_parse_triplet_list.cmake

# 1. Include the test_utilities and the module to test
include("${CMAKE_CURRENT_LIST_DIR}/../test_utilities.cmake")
include(utils)
include(warning_summary) # <-- FIX: Include module to define 

# 2. Define test cases
message(STATUS "Running test: kis_parse_triplet_list")

# --- Test Case 1: Empty List ---
set(input_list "")
kis_parse_triplet_list(
    INPUT_LIST "${input_list}"
    NAMES_OUT names
    REMOTES_OUT remotes
)
assert_equal("${names}" "")
assert_equal("${remotes}" "")

# --- Test Case 2: Simple Names Only ---
set(input_list "kis_core,kis_system")
kis_parse_triplet_list(
    INPUT_LIST "${input_list}"
    NAMES_OUT names
    REMOTES_OUT remotes
)
assert_equal("${names}" "kis_core,kis_system")
assert_equal("${remotes}" "")

# --- Test Case 3: Full Triplets Only ---
set(input_list 
    "kis_core;https://a.com/core;main"
    "kis_system;https://b.com/system;develop"
)
kis_parse_triplet_list(
    INPUT_LIST "${input_list}"
    NAMES_OUT names
    REMOTES_OUT remotes
)
assert_equal("${names}" "kis_core;kis_system")
assert_equal("${remotes}" "kis_core;https://a.com/core;main;kis_system;https://b.com/system;develop")

# --- Test Case 4: Mixed List (Names and Triplets) ---
set(input_list 
    "kis_core"
    "kis_system;https://b.com/system;develop"
    "kis_renderer"
)
kis_parse_triplet_list(
    INPUT_LIST "${input_list}"
    NAMES_OUT names
    REMOTES_OUT remotes
)
assert_equal("${names}" "kis_core;kis_system;kis_renderer")
assert_equal("${remotes}" "kis_system;https://b.com/system;develop")

# --- Test Case 5: Order-Independence Check 1 (User's failing case) ---
set(input_list 
    "kis_core;https://a.com/core;main"
    "kis_system;https://b.com/system;develop"
)
kis_parse_triplet_list(
    INPUT_LIST "${input_list}"
    NAMES_OUT names
    REMOTES_OUT remotes
)
assert_equal("${names}" "kis_core;kis_system")

# --- Test Case 6: Order-Independence Check 2 (Swapped) ---
set(input_list 
    "kis_system;https://b.com/system;develop"
    "kis_core;https://a.com/core;main"
)
kis_parse_triplet_list(
    INPUT_LIST "${input_list}"
    NAMES_OUT names
    REMOTES_OUT remotes
)
assert_equal("${names}" "kis_system;kis_core") # Note: order of names should be preserved, but both must be present

# --- Test Case 7: Malformed list (URL without tag) ---
set(input_list "kis_core;https://a.com/core")
kis_parse_triplet_list(
    INPUT_LIST "${input_list}"
    NAMES_OUT names
    REMOTES_OUT remotes
)
assert_equal("${names}" "kis_core")
assert_equal("${remotes}" "") # Malformed triplet should not be added to remotes

message(STATUS "PASS: kis_parse_triplet_list")