import Foundation
import CWinAppSDK
import WinSDK
import WinUI

@main
enum ArcSwiftWinApp {
    public static func main() async throws {
        RoInitialize(RO_INIT_SINGLETHREADED)

        MddBootstrapInitialize2(
            UInt32(WINDOWSAPPSDK_RELEASE_MAJORMINOR),
            WINDOWSAPPSDK_RELEASE_VERSION_TAG_SWIFT,
            .init(),
            MddBootstrapInitializeOptions(MddBootstrapInitializeOptions_OnNoMatch_ShowUI.rawValue | MddBootstrapInitializeOptions_OnError_DebugBreak_IfDebuggerAttached.rawValue)
        )

        defer {
            MddBootstrapShutdown()
        }

        Application.start { _ in
            _ = PreviewApp()
        }
    }
}
