# This file handles running swiftwinrt.exe to generate Swift bindings for WinRT. This is done as part of the configure stage of the build.
# When making a change to the file, you need to re-run configure. If you're building from VSCode, this will happen automatically for you.
# From the command line, you can run `cmake --preset debug` (or `cmake --preset release`) to re-run configure.

if("${REPO_ROOT}" STREQUAL "")
  message(FATAL_ERROR "REPO_ROOT must be set before including WinRTPreBuild")
endif()

set(SWIFTWINRT_OUTPUT_DIR ${GENERATED_FILES_DIR}/Shared/WinRT)
set(FRAMEWORKS_WINRT_DIR ${REPO_ROOT}/Shared/WinRT)
if(${CMAKE_VERSION} VERSION_LESS "3.26.0")
  # Required for copy_directory_if_different.
  message(FATAL_ERROR "CMake 3.26.0 or later is required, please install the latest via: winget install Kitware.CMake. You will need to delete the build directory after updating cmake.")
endif()

# WinRT namespaces and types for which to generate bindings.
set(SWIFT_WINRT_PARAMETERS
  "-include Microsoft.UI.ColorHelper"
  "-include Microsoft.UI.Colors"
  "-include Microsoft.UI.Composition.SpringVector3NaturalMotionAnimation"
  "-include Microsoft.UI.Composition.SystemBackdrops"
  "-include Microsoft.UI.Dispatching.DispatcherQueueController"
  "-include Microsoft.UI.Input"
  "-include Microsoft.UI.Windowing.AppWindowTitleBar"
  "-include Microsoft.UI.Windowing.OverlappedPresenter"
  "-include Microsoft.UI.Xaml.Application"
  "-include Microsoft.UI.Xaml.Automation.AutomationProperties"
  "-include Microsoft.UI.Xaml.Controls.Border"
  "-include Microsoft.UI.Xaml.Controls.Button"
  "-include Microsoft.UI.Xaml.Controls.Canvas"
  "-include Microsoft.UI.Xaml.Controls.ColumnDefinition"
  "-include Microsoft.UI.Xaml.Controls.ContentDialog"
  "-include Microsoft.UI.Xaml.Controls.ContentPresenter"
  "-include Microsoft.UI.Xaml.Controls.FlipView"
  "-include Microsoft.UI.Xaml.Controls.FlipViewItem"
  "-include Microsoft.UI.Xaml.Controls.Flyout"
  "-include Microsoft.UI.Xaml.Controls.FlyoutPresenter"
  "-include Microsoft.UI.Xaml.Controls.FontIcon"
  "-include Microsoft.UI.Xaml.Controls.FontIconSource"
  "-include Microsoft.UI.Xaml.Controls.Grid"
  "-include Microsoft.UI.Xaml.Controls.GridView"
  "-include Microsoft.UI.Xaml.Controls.IconSourceElement"
  "-include Microsoft.UI.Xaml.Controls.IKeyIndexMapping"
  "-include Microsoft.UI.Xaml.Controls.Image"
  "-include Microsoft.UI.Xaml.Controls.ItemsRepeater"
  "-include Microsoft.UI.Xaml.Controls.MenuFlyout"
  "-include Microsoft.UI.Xaml.Controls.MenuFlyoutItem"
  "-include Microsoft.UI.Xaml.Controls.MenuFlyoutSeparator"
  "-include Microsoft.UI.Xaml.Controls.MenuFlyoutSubItem"
  "-include Microsoft.UI.Xaml.Controls.Page"
  "-include Microsoft.UI.Xaml.Controls.PipsPager"
  "-include Microsoft.UI.Xaml.Controls.Primitives.ScrollSnapPoint"
  "-include Microsoft.UI.Xaml.Controls.Primitives.ScrollSnapPointsAlignment"
  "-include Microsoft.UI.Xaml.Controls.RadioButton"
  "-include Microsoft.UI.Xaml.Controls.RadioButtons"
  "-include Microsoft.UI.Xaml.Controls.RelativePanel"
  "-include Microsoft.UI.Xaml.Controls.RowDefinition"
  "-include Microsoft.UI.Xaml.Controls.ScrollViewer"
  "-include Microsoft.UI.Xaml.Controls.SplitView"
  "-include Microsoft.UI.Xaml.Controls.StackLayout"
  "-include Microsoft.UI.Xaml.Controls.StackPanel"
  "-include Microsoft.UI.Xaml.Controls.TeachingTip"
  "-include Microsoft.UI.Xaml.Controls.TextBlock"
  "-include Microsoft.UI.Xaml.Controls.TextBox"
  "-include Microsoft.UI.Xaml.Controls.TextBox"
  "-include Microsoft.UI.Xaml.Controls.TreeView"
  "-include Microsoft.UI.Xaml.Controls.TreeViewItem"
  "-include Microsoft.UI.Xaml.Controls.TreeViewList"
  "-include Microsoft.UI.Xaml.Controls.XamlControlsResources"
  "-include Microsoft.UI.Xaml.Hosting.ElementCompositionPreview"
  "-include Microsoft.UI.Xaml.Hosting.WindowsXamlManager"
  "-include Microsoft.UI.Xaml.Input.FocusManager"
  "-include Microsoft.UI.Xaml.Interop.INotifyCollectionChanged"
  "-include Microsoft.UI.Xaml.Markup.IComponentConnector"
  "-include Microsoft.UI.Xaml.Markup.IDataTemplateComponent"
  "-include Microsoft.UI.Xaml.Media.Animation"
  "-include Microsoft.UI.Xaml.Media.CompositeTransform"
  "-include Microsoft.UI.Xaml.Media.CompositionTarget"
  "-include Microsoft.UI.Xaml.Media.Imaging"
  "-include Microsoft.UI.Xaml.Media.MicaBackdrop"
  "-include Microsoft.UI.Xaml.Media.Transform"
  "-include Microsoft.UI.Xaml.Media.TranslateTransform"
  "-include Microsoft.UI.Xaml.Media.VisualTreeHelper"
  "-include Microsoft.UI.Xaml.Setter"
  "-include Microsoft.UI.Xaml.Shapes.Ellipse"
  "-include Microsoft.UI.Xaml.Shapes.Path"
  "-include Microsoft.UI.Xaml.Shapes.Rectangle"
  "-include Microsoft.UI.Xaml.Window"
  "-include Microsoft.UI.Xaml.XamlTypeInfo.XamlControlsXamlMetaDataProvider"
  "-include Microsoft.Windows.AppLifecycle.AppInstance"
  "-include Windows.ApplicationModel.DataTransfer"
  "-include Windows.Management.Deployment.PackageManager"
  "-exclude Windows.Management.Deployment.PackageStatus"
  "-include Windows.Foundation.IPropertyValue"
  "-include Windows.Graphics.Imaging"
  "-include Windows.Storage.Streams"
  "-include Windows.System.Diagnostics.SystemDiagnosticInfo"
  "-include Windows.UI.Text.FontWeights"
  "-include Windows.UI.ViewManagement.UISettings"
)

# Additional parameters.
set(SWIFT_WINRT_PARAMETERS ${SWIFT_WINRT_PARAMETERS}
  "-support WindowsFoundation"
  "-log"
  "-output ${SWIFTWINRT_OUTPUT_DIR}"
  "${WINAPP_SDK_WINMD_INPUT}"
  "${WINDOWSSDK_WINMD_REF}"
)

string(REPLACE ";" "\n" SWIFT_WINRT_PARAMETERS "${SWIFT_WINRT_PARAMETERS}")

# swift/winrt is run in the configure stage of the build, because when swift/winrt runs, it outputs all files,
# which means that the build system will think that the build is out of date and will re-build all of the bindings.
# so we can use cmake's copy_if_different to only copy files that have changed, but that has to run as part of configure.

set(SWIFTWINRT_RSP ${GENERATED_FILES_DIR}/SwiftWinRT.rsp)
set(SWIFTWINRT_TEMP_RSP ${GENERATED_FILES_DIR}/SwiftWinRT_TEMP.rsp)

# First write parameters to swiftwinrt in a temp file. If the parameters change from the
# previous execution then we need to re-run swiftwinrt.
file(WRITE ${SWIFTWINRT_TEMP_RSP} ${SWIFT_WINRT_PARAMETERS})

execute_process(
  COMMAND ${CMAKE_COMMAND} -E compare_files ${SWIFTWINRT_TEMP_RSP} ${SWIFTWINRT_RSP}
  RESULT_VARIABLE compare_result
)

# When iterating on swiftwinrt and wanting to test something in Arc, it's useful to be able to set this
# override so that you can point this to your local version on disk. You can set SWIFT_WINRT_OVERRIDE_DIR
# via something like the line below:
set(SWIFTWINRT_DIR ${PkgTheBrowserCompany_SwiftWinRT}/bin)

set(SWIFTWINRT_EXE ${SWIFTWINRT_DIR}/swiftwinrt.exe)
if(NOT EXISTS ${SWIFTWINRT_EXE})
  message(FATAL_ERROR "swiftwinrt.exe not found at ${SWIFTWINRT_EXE}. Did NuGet restore fail?")
endif()

# Hash swiftwinrt and make sure it's up-to-date. If it changes we need to re-run swiftwinrt.
file(SHA256 ${SWIFTWINRT_EXE} SWIFT_WINRT_CHECKSUM)

# Read previous checksum from file on disk.
if(EXISTS ${GENERATED_FILES_DIR}/SwiftWinRT.checksum)
  file(READ ${GENERATED_FILES_DIR}/SwiftWinRT.checksum SWIFTWINRT_CHECKSUM_PREVIOUS)
else()
  set(SWIFTWINRT_CHECKSUM_PREVIOUS "0")
endif()

set(SWIFTWINRT_DIRTY 0)
if(NOT ${SWIFT_WINRT_CHECKSUM} STREQUAL ${SWIFTWINRT_CHECKSUM_PREVIOUS})
  message(STATUS "swiftwinrt.exe has changed...")
  set(SWIFTWINRT_DIRTY 1)
endif()

file(WRITE ${GENERATED_FILES_DIR}/SwiftWinRT.checksum ${SWIFT_WINRT_CHECKSUM})
if(compare_result EQUAL 0 AND ${SWIFTWINRT_DIRTY} EQUAL 0)
  message(STATUS "swiftwinrt up-to-date")
elseif(compare_result EQUAL 1 OR ${SWIFTWINRT_DIRTY} EQUAL 1)
  message(STATUS "Running swiftwinrt...")

  # Remove the previous swiftwinrt generated files so stale files are not copied.
  file(REMOVE_RECURSE ${SWIFTWINRT_OUTPUT_DIR})

  execute_process(
    COMMAND ${SWIFTWINRT_EXE} @${SWIFTWINRT_TEMP_RSP}
    COMMAND_ERROR_IS_FATAL ANY
  )
  message(STATUS "swifwinrt completed")

  # Update the file, run this after we know swiftwinrt has succeeded.
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy ${SWIFTWINRT_TEMP_RSP} ${SWIFTWINRT_RSP}
  )

  execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different ${SWIFTWINRT_OUTPUT_DIR} ${FRAMEWORKS_WINRT_DIR}
  )
else()
    message("Error while comparing the files.")
endif()

# Add swiftwinrt generated files to clean list.
file(GLOB_RECURSE SWIFTWINRT_GENERATED_FILES ${FRAMEWORKS_WINRT_DIR}/*)
list(LENGTH SWIFTWINRT_GENERATED_FILES SWIFTWINRT_GENERATED_FILES_LENGTH)

# Don't remove package.swift files or handwritten files from clean.
foreach(item IN LISTS SWIFTWINRT_GENERATED_FILES)
    if(item MATCHES ".*Package.swift" OR item MATCHES ".*\\+Handwritten.swift")
        list(REMOVE_ITEM SWIFTWINRT_GENERATED_FILES ${item})
    endif()
endforeach()

# Add generated files to clean.
set_property(DIRECTORY
  APPEND
  PROPERTY ADDITIONAL_CLEAN_FILES ${SWIFTWINRT_GENERATED_FILES}
)

set_property(DIRECTORY
  APPEND
  PROPERTY ADDITIONAL_CLEAN_FILES ${SWIFTWINRT_RSP}
)
