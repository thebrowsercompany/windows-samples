# Only support x64 for now.
set(TARGET_PLATFORM x64)

get_filename_component(BUILD_OUTPUT_ROOT ${REPO_ROOT}/build ABSOLUTE CACHE)

get_filename_component(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${BUILD_OUTPUT_ROOT}/lib ABSOLUTE CACHE)
get_filename_component(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${BUILD_OUTPUT_ROOT}/lib ABSOLUTE CACHE)
get_filename_component(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BUILD_OUTPUT_ROOT}/bin ABSOLUTE CACHE)

# Kill the executable we're going to rebuild so the build doesn't fail.
string(REPLACE "/" "\\\\" WMI_PATH_PATTERN ${BUILD_OUTPUT_ROOT})
execute_process(
  COMMAND wmic process where "ExecutablePath like '${WMI_PATH_PATTERN}\\\\%' and ExecutablePath like '%\\\\${CMAKE_PROJECT_NAME}.exe'" call terminate
  ERROR_QUIET
)

include(WinRTPreBuild)
include(spm)
include(WindowsApplicationSetup)
