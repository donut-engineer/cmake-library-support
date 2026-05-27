include(coverage)
include(sanitizers)

if(CONSUMER_LANG STREQUAL "CXX")
  # C++ consumer: drive the library through a GoogleTest suite.
  include(FetchContent)
  FetchContent_Declare(
    googletest
    URL                    https://github.com/google/googletest/archive/refs/tags/v1.14.0.tar.gz
    URL_HASH               SHA256=8ad598c73ad796e0d8280b082cebd82a630d73e73cd3c70057938a6501bba5d7
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  )
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  FetchContent_MakeAvailable(googletest)
  include(GoogleTest)

  add_executable(test_mylib test_mylib.cpp)
  target_link_libraries(test_mylib PRIVATE mylib GTest::gtest_main)
  gtest_discover_tests(test_mylib)
else()
  # C consumer: a plain-C test, so the C path carries no C++ dependency.
  add_executable(test_mylib test_mylib.c)
  target_link_libraries(test_mylib PRIVATE mylib)
  add_test(NAME test_mylib COMMAND test_mylib)
endif()

# Exercise target_enable_coverage on both the library and its test driver so that
# gcovr collects coverage data for the library source, not just the test executable.
target_enable_coverage(TARGET mylib)
target_enable_coverage(TARGET test_mylib)

# Exercise target_enable_sanitizers (adds -fsanitize=address,undefined -fno-omit-frame-pointer)
target_enable_sanitizers(TARGET test_mylib ADDRESS UNDEFINED)

# Exercise add_coverage_report_target (creates 'coverage' custom target)
add_coverage_report_target(TEST_TARGET test_mylib)
