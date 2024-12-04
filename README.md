# Swift on Windows Samples Apps

> [!WARNING]
> This project uses an outdated snapshot of a subset of WinRT projections generated with [swift-winrt](https://github.com/thebrowsercompany/swift-winrt), provided for illustration purposes. To use WinRT APIs in your Swift project, we recommend using [swift-winrt](https://github.com/thebrowsercompany/swift-winrt) directly to generate your own projections.

Sample apps for Swift on Windows, showcasing how to build Windows Apps using the [Windows App SDK](https://github.com/microsoft/windowsappsdk) through the [Swift/WinRT](https://github.com/thebrowsercompany/swift-winrt) language projection.

## Setup

### Requirements
1. Install latest Swift SDK from [thebrowsercompany/swift-build](https://github.com/thebrowsercompany/swift-build/releases)
2. Visual Studio Community with C++ build tools
3. Make sure to have the appropriate version of the Windows App Runtime installed as mentioned [here](https://github.com/thebrowsercompany/swift-windowsappsdk?tab=readme-ov-file#using-windows-app-sdk)
 
### VSCode

VSCode is the editor of choice for developing Windows apps on Swift. You can install it from https://code.visualstudio.com/download.

If you choose to use Visual Studio Code, you'll need to install these extensions:
- [Swift VSCode Extension](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang)

## Building

The build of the Windows applications is done through SPM. This can be done on the command line with `swift build` or in Visual Studio Code with `Ctrl+Shift+B`.

### Debugging in VSCode

Debugging in VSCode is supported through LLDB. You can simply press `F5` or navigate to the `Run and Debug` (`Ctrl+Shift+D`) pane.
