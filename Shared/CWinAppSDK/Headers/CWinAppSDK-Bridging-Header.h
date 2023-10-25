#include <wtypesbase.h>
#include <minwindef.h>
#include <winnt.h>
#include <combaseapi.h>

#include <roapi.h>
#include <winstring.h>
#include "stdlib.h"
#include <MddBootstrap.h>
#include <WindowsAppSDK-VersionInfo.h>

// re-define the string to make it visible in Swift. (#define only supports numbers & strings)
static PCWSTR WINDOWSAPPSDK_RELEASE_VERSION_TAG_SWIFT = WINDOWSAPPSDK_RELEASE_VERSION_TAG_W;