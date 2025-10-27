# --- 8. Optional Components ---
if(KIS_BUILD_TESTS)
    enable_testing()
    # Assumes CTest is configured.

    # Glob sources for tests (CMAKE_CURRENT_SOURCE_DIR is already the 'secondary' folder)
    file(GLOB_RECURSE TEST_SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.cpp"
    )
    
    kis_add_test(${PACKAGE_NAME}_tests
        SOURCES
            ${TEST_SOURCES}
    )
endif()

if(KIS_BUILD_SAMPLES)
#    kis_add_sample(my_package_hello_world
#       SOURCES
#            samples/hello_world.cpp
#    )
endif()

if(KIS_BUILD_BENCHMARKS)
 #   kis_add_benchmark(my_package_perf_benchmark
 #       SOURCES
 #           benchmarks/performance.bench.cpp
 #   )
endif()