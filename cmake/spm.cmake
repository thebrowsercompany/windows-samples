include(ExternalProject)

# SPM can't be used to build as administrator and then as a regular user,
# because the regular user won't have access to some files created as administrator.
# Avoid this pitfall during local development by preventing administrator builds.
  # "net session" is a standard way of testing for admin rights.
execute_process(
  COMMAND "net" "session"
  RESULT_VARIABLE NET_SESSION_EXIT_CODE
  OUTPUT_QUIET ERROR_QUIET)
if(${NET_SESSION_EXIT_CODE} EQUAL 0)
  message(FATAL_ERROR "Running builds as administrator is not supported. Please use a non-elevated Visual Studio Code or Terminal instance.")
endif()

# Swift package resolving happens in the IDE, there's no need to run it as part of the build and add seconds to
# what should otherwise be very fast builds.
set(SWIFT_BUILD_ARGS --disable-automatic-resolution -Xswiftc -g)

# Workaround for swiftc hang with 64 core machines
if($ENV{NUMBER_OF_PROCESSORS} EQUAL 64)
  set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} -j 8)
endif()

# If you want to debug in WinDBG or Visual Studio, choose the Debug (PDB) preset
# in cmake, this will define the BUILD_FOR_PDB variable.
if(DEFINED ENV{BUILD_FOR_PDB})
  set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} -Xswiftc -debug-info-format=codeview -Xlinker -debug)
else()
  set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} -Xlinker -debug:dwarf)
endif()

# Ignore "locally defined symbol imported" warnings caused by SPM static/dynamic linking limitations.
set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} -Xlinker -ignore:4217)

set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} -Xcc -I${PkgMicrosoft_WindowsAppSDK}/include)
set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} -Xlinker -L${PkgMicrosoft_WindowsAppSDK}/lib/win10-${TARGET_PLATFORM})

if("$ENV{SWIFT_VERBOSITY}" STREQUAL "informational")
  set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} -v)
elseif("$ENV{SWIFT_VERBOSITY}" STREQUAL "debug")
  set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} -vv)
elseif("$ENV{SWIFT_VERBOSITY}" STREQUAL "incremental")
  # Get better understanding of incremental builds.
  set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} -Xswiftc -v -Xswiftc -driver-show-incremental)
endif()

# SPM requires build config to be in lower case.
string(TOLOWER ${CMAKE_BUILD_TYPE} SPM_BUILD_TYPE)
set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} -c ${SPM_BUILD_TYPE})

# Set output directory.
set(SPM_BUILD_DIR ${BUILD_OUTPUT_ROOT}/spm)
set(SWIFT_BUILD_ARGS ${SWIFT_BUILD_ARGS} --scratch-path ${SPM_BUILD_DIR})

# Work around https://github.com/microsoft/vscode-cmake-tools/issues/3143.
set(SWIFT_COMMAND ${CMAKE_COMMAND} -E env --unset=VCINSTALLDIR CC=clang CXX=clang++ -- swift build ${SWIFT_BUILD_ARGS})

ExternalProject_Add(${CMAKE_PROJECT_NAME}-SPM
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    INSTALL_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${SWIFT_COMMAND}
    BUILD_IN_SOURCE true
    BUILD_ALWAYS ON
    BUILD_BYPRODUCTS ${SPM_BUILD_DIR}/${SPM_BUILD_TYPE}/${CMAKE_PROJECT_NAME}.exe
    COMMENT "Running Swift build..."
)

ExternalProject_Get_Property(${CMAKE_PROJECT_NAME}-SPM BINARY_DIR)

set(SPM_BIN_DIR ${SPM_BUILD_DIR}/x86_64-unknown-windows-msvc/${SPM_BUILD_TYPE})

set_property(DIRECTORY
  APPEND
  PROPERTY ADDITIONAL_CLEAN_FILES ${SPM_BIN_DIR}/
)
