function(assert_variable ARG_VARIABLE ARG_MESSAGE)
  if(NOT DEFINED ${ARG_VARIABLE})
    message(FATAL_ERROR ${ARG_MESSAGE})
  endif()
endfunction()

function(nuget_download ARG_VERSION ARG_DOWNLOAD_PATH)
  set(URL "https://dist.nuget.org/win-x86-commandline/${ARG_VERSION}/nuget.exe")
  file(DOWNLOAD ${URL} "${ARG_DOWNLOAD_PATH}/nuget.exe")
  message(STATUS "[ NuGet ] Downloaded ${URL} to ${ARG_DOWNLOAD_PATH}")
endfunction()

function(nuget_init)
  set(flagArgs SKIP_DOWNLOAD)
  set(oneValueArgs VERSION DOWNLOAD_PATH)
  set(multiValueArgs)
  cmake_parse_arguments(
      NUGET
      "${flagArgs}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

  # Use the latest version if no NUGET_VERSION is specified.
  if(NOT DEFINED NUGET_VERSION)
    set(NUGET_VERSION "latest")
  endif()

  assert_variable(NUGET_VERSION "You must specify the NUGET_VERSION")
  assert_variable(
      NUGET_DOWNLOAD_PATH "You must specify the NUGET_DOWNLOAD_PATH")
  set(ENV{NUGET_DOWNLOAD_PATH} ${NUGET_DOWNLOAD_PATH})
  set(ENV{NUGET_BINARY_PATH} ${NUGET_DOWNLOAD_PATH}/nuget.exe)
  if(NUGET_SKIP_DOWNLOAD)
    message(STATUS "[ NuGet ] Skipping the NuGet.exe download.")
  elseif(NOT EXISTS $ENV{NUGET_BINARY_PATH})
    nuget_download(${NUGET_VERSION} ${NUGET_DOWNLOAD_PATH})
  endif()
endfunction()

# Parse the packages.config file and extract the id and version of the package.
# Each package name is translated into a "PkgFoo_Bar" variable, replacing every "."
# with a "_". These variables point to the package location on disk of the package.
function(set_package_variables ARG_PACKAGES_CONFIG ARG_INSTALL_PATH)
  set(ID_REGEX "\\i\\d\\=\"([A-Za-z0-9_\\.\\-]+)\"")
  set(VERSION_REGEX "\\v\\e\\r\\s\\i\\o\\n=\"([A-Za-z0-9_\\.\\-]+)\"")
  set(PACKAGE_REGEX "${ID_REGEX} ${VERSION_REGEX}")
  file(STRINGS ${ARG_PACKAGES_CONFIG} PACKAGE_CONFIG_CONTENTS)
  foreach(LINE ${PACKAGE_CONFIG_CONTENTS})
    if(${LINE} MATCHES ${PACKAGE_REGEX})
      string(REPLACE "." "_" PACKAGE_VARIABLE_NAME ${CMAKE_MATCH_1})
      string(PREPEND PACKAGE_VARIABLE_NAME "Pkg")
      set(PACKAGE_PATH_VALUE "${ARG_INSTALL_PATH}/${CMAKE_MATCH_1}.${CMAKE_MATCH_2}")
      set(${PACKAGE_VARIABLE_NAME} ${PACKAGE_PATH_VALUE} PARENT_SCOPE)

      # Set package version variables. Since regular expressions are a nightmare,
      # we simply transform the string and manually parse the parts.
      set("${PACKAGE_VARIABLE_NAME}_Version" ${CMAKE_MATCH_2} PARENT_SCOPE)
      string(FIND ${CMAKE_MATCH_2} "-" PRERELEASE_INDEX REVERSE)
      string(REPLACE "." "-" VERSION_PARTS ${CMAKE_MATCH_2})
      string(REPLACE "-" ";" VERSION_PARTS ${VERSION_PARTS})
      list(LENGTH VERSION_PARTS VERSION_LENGTH)
      list(GET VERSION_PARTS 0 VER_MAJOR)
      list(GET VERSION_PARTS 1 VER_MINOR)
      list(GET VERSION_PARTS 2 VER_PATCH)
      set("${PACKAGE_VARIABLE_NAME}_Version_MAJOR" ${VER_MAJOR} PARENT_SCOPE)
      set("${PACKAGE_VARIABLE_NAME}_Version_MINOR" ${VER_MINOR} PARENT_SCOPE)
      set("${PACKAGE_VARIABLE_NAME}_Version_PATCH" ${VER_PATCH} PARENT_SCOPE)

      # Determine if the 4th part is a build or pre-release label.
      if(${VERSION_LENGTH} GREATER 4 OR (${VERSION_LENGTH} EQUAL 4 AND ${PRERELEASE_INDEX} EQUAL -1))
        list(GET VERSION_PARTS 3 VER_BUILD)
        set("${PACKAGE_VARIABLE_NAME}_Version_BUILD" ${VER_BUILD} PARENT_SCOPE)
      elseif(${VERSION_LENGTH} EQUAL 4 AND NOT ${PRERELEASE_INDEX} EQUAL -1)
        list(GET VERSION_PARTS 3 VER_PRERELEASE)
        set("${PACKAGE_VARIABLE_NAME}_Version_PRERELEASE" ${VER_PRERELEASE} PARENT_SCOPE)
      endif()

      # 5th part is always going to be a pre-release label.
      if(${VERSION_LENGTH} GREATER_EQUAL 5)
        list(GET VERSION_PARTS 4 VER_PRERELEASE)
        set("${PACKAGE_VARIABLE_NAME}_Version_PRERELEASE" ${VER_PRERELEASE} PARENT_SCOPE)
      endif()
    endif()
  endforeach()
endfunction()

# NOTE: We use macro(s) for the below restore "functions" so that the Package
# variables are properly set in the parent scope.
macro(nuget_restore)
  set(flagArgs )
  set(oneValueArgs PACKAGES CONFIG INSTALL_DIR)
  set(multiValueArgs LOCK_ARGS)
  cmake_parse_arguments(
      NUGET
      "${flagArgs}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})
  set(NUGET_BINARY_PATH $ENV{NUGET_BINARY_PATH})
  execute_process(COMMAND "${NUGET_BINARY_PATH}" restore
    -NonInteractive
    -ConfigFile ${NUGET_CONFIG}
    -PackagesDirectory ${NUGET_INSTALL_DIR}
    ${NUGET_LOCK_ARGS}
    ${NUGET_PACKAGES}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE ret_code
    ERROR_VARIABLE NUGET_INSTALL_ERROR_OUTPUT
    OUTPUT_VARIABLE NUGET_INSTALL_OUTPUT)
    if(NOT "${NUGET_INSTALL_ERROR_OUTPUT}" STREQUAL "")
      message(FATAL_ERROR "${NUGET_INSTALL_ERROR_OUTPUT}")
    endif()
    if(NOT "${NUGET_INSTALL_OUTPUT}" STREQUAL "")
      message(STATUS "${NUGET_INSTALL_OUTPUT}")
    endif()
   set_package_variables(${NUGET_PACKAGES} ${NUGET_INSTALL_DIR})
endmacro()

set(NUGET_CONFIG_LOCATION ${REPO_ROOT}/nuget)

nuget_init(DOWNLOAD_PATH ${BUILD_OUTPUT_ROOT})

set(PACKAGE_INSTALL_LOCATION ${BUILD_OUTPUT_ROOT}/NugetPackages)
nuget_restore(PACKAGES ${NUGET_CONFIG_LOCATION}/packages.config
  CONFIG ${NUGET_CONFIG_LOCATION}/NuGet.config
  INSTALL_DIR ${PACKAGE_INSTALL_LOCATION}
)
