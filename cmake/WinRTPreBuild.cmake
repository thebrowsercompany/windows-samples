# Nuget is the first thing we need to do, this will restore all the packages
# and set path variables to point to those packages on disk.
include(nuget)

set(GENERATED_FILES_DIR ${CMAKE_BINARY_DIR}/generated)

if(NOT EXISTS ${GENERATED_FILES_DIR})
  file(MAKE_DIRECTORY ${GENERATED_FILES_DIR})
endif()

set_property(DIRECTORY
  APPEND
  PROPERTY ADDITIONAL_CLEAN_FILES ${GENERATED_FILES_DIR}
)

if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "AMD64")
    set(WINSDK_BIN_ARCH x64)
else()
    set(WINSDK_BIN_ARCH ${CMAKE_SYSTEM_PROCESSOR})
endif()

# The windows sdk build tools are in a versioned subfolder of the nuget package.
set(WINDSDK_BUILDTOOLS_BIN_VER ${PkgMicrosoft_Windows_SDK_BuildTools_Version_MAJOR}.${PkgMicrosoft_Windows_SDK_BuildTools_Version_MINOR}.${PkgMicrosoft_Windows_SDK_BuildTools_Version_PATCH}.0)
set(WINSDK_BUILDTOOLS_BIN_DIR ${PkgMicrosoft_Windows_SDK_BuildTools}/bin/${WINDSDK_BUILDTOOLS_BIN_VER}/${WINSDK_BIN_ARCH})
set(WindowsSDK_Ver 10.0.20348.0)
set(WinAppSDK_WinMD_Dir ${PkgMicrosoft_WindowsAppSDK}/lib/uap10.0)
set(WinAppSDK_WinMD_Dir_Ver ${PkgMicrosoft_WindowsAppSDK}/lib/uap10.0.17763)

file(GLOB WINAPP_SDK_WINMDS ${WinAppSDK_WinMD_Dir}/*.winmd)
file(GLOB WINAPP_SDK_WINMDS_VER ${WinAppSDK_WinMD_Dir_Ver}/*.winmd)
list(APPEND WINAPP_SDK_WINMDS ${WINAPP_SDK_WINMDS_VER})

set(WindowsSDK_WinMD_DIR "$ENV{WindowsSdkDir}/References/${WindowsSDK_Ver}")

list(TRANSFORM WINAPP_SDK_WINMDS PREPEND "-input " OUTPUT_VARIABLE WINAPP_SDK_WINMD_INPUT)
list(TRANSFORM WINAPP_SDK_WINMDS PREPEND "-reference " OUTPUT_VARIABLE WINAPP_SDK_WINMD_REF)

# Grab all of the windows sdk winmds.
file(GLOB_RECURSE WINDOWSSDK_WINMDS ${WindowsSDK_WinMD_DIR}/*.winmd)

# Wrap the paths in quotes because otherwise they have spaces in them.
list(TRANSFORM WINDOWSSDK_WINMDS PREPEND "\"" OUTPUT_VARIABLE WINDOWSSDK_WINMDS)
list(TRANSFORM WINDOWSSDK_WINMDS APPEND "\"" OUTPUT_VARIABLE WINDOWSSDK_WINMDS)

list(TRANSFORM WINDOWSSDK_WINMDS PREPEND "-input " OUTPUT_VARIABLE WINDOWSSDK_WINMD_INPUT)
list(TRANSFORM WINDOWSSDK_WINMDS PREPEND "-reference " OUTPUT_VARIABLE WINDOWSSDK_WINMD_REF)

include(swiftwinrt)
