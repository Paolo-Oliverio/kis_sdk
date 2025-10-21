# --- 8. Optional Components ---
if(KIS_BUILD_TESTS)
    enable_testing()
    # Assumes CTest or similar is configured.

    kis_handle_dependency(doctest
        GIT_REPOSITORY https://github.com/doctest/doctest.git
        GIT_TAG        ${KIS_THIRDPARTY_DOCTEST_VERSION}
    )

    # Glob sources for tests (CMAKE_CURRENT_SOURCE_DIR is already the 'secondary' folder)
    file(GLOB_RECURSE TEST_SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.cpp"
    )
    
    kis_add_test(${PACKAGE_NAME}_tests
        SOURCES
            ${TEST_SOURCES}
        LINK_LIBRARIES
            # Link to our main library target
            kis::${PACKAGE_NAME}
            # Crucially, link to the doctest target. This provides the
            # include paths and any other usage requirements.
            doctest::doctest
    )
endif()

if(KIS_BUILD_SAMPLES)
#    kis_add_sample(my_package_hello_world
 #       SOURCES
#            samples/hello_world.cpp
#        LINK_LIBRARIES
#            ${PACKAGE_NAME}       # Link against our main library
#    )
endif()

if(KIS_BUILD_BENCHMARKS)
 #   kis_add_benchmark(my_package_perf_benchmark
 #       SOURCES
 #           benchmarks/performance.bench.cpp
 #       LINK_LIBRARIES
 #           ${PACKAGE_NAME}
 #           benchmark             # Example: Link against Google Benchmark
 #   )
endif()