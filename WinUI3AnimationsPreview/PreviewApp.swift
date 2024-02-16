import Foundation
import UWP
import WinAppSDK
import WindowsFoundation
import WinUI

@main
public class PreviewApp: SwiftApplication {
    /// A required initializer for the application. Non-UI setup for your application can be done here.
    /// Subscribing to unhandledException is a good place to handle any unhandled exceptions that may occur
    /// in your application.
    public required init() {
        super.init()
        unhandledException.addHandler { (_, args:UnhandledExceptionEventArgs!) in
            print("Unhandled exception: \(args.message)")
        }
    }

    /// onShutdown is called once Application.start returns. This is a good place to do any cleanup
    /// that is necessary for your application before it terminates.
    override public func onShutdown() {    }

    /// onLaunched is called when the application is launched. This is the main entry point for your
    /// application and when you can create a window and display UI.s
    override public func onLaunched(_ args: WinUI.LaunchActivatedEventArgs) {
        let window = Window()
        window.title = "WinUI3AnimationsPreview"

        try! window.activate()

        let animatableButton = Button()
        animatableButton.content = "Hello World"

        animatableButton.pointerEntered.addHandler { [weak self] in
            guard let self else { return }
            self.elementPointerEntered(sender: $0, args: $1)
        }
        animatableButton.pointerExited.addHandler { [weak self] in
            guard let self else { return }
            self.elementPointerExited(sender: $0, args: $1)
        }

        // initialize the animation to scale of 1.0 so that it can be scaled up when first
        // hovered over. do it on load or else we don't have a compositor ready yet
        animatableButton.loaded.addHandler { [weak self] _, _ in
            guard let self else { return }
            self.springAnimation.finalValue = Vector3(x: 1.0, y: 1.0, z: 1.0)
        }

        let panel = StackPanel()
        panel.orientation = .vertical
        panel.spacing = 10
        panel.horizontalAlignment = .center
        panel.verticalAlignment = .center
        panel.children.append(animatableButton)
        window.content = panel
    }

    lazy var compositor: WinAppSDK.Compositor = WinUI.CompositionTarget.getCompositorForCurrentThread()
    lazy var springAnimation: WinAppSDK.SpringVector3NaturalMotionAnimation = {
        // swiftlint:disable:next force_try
        let animation: WinAppSDK.SpringVector3NaturalMotionAnimation = try! compositor.createSpringVector3Animation()
        animation.target = "Scale"
        animation.dampingRatio = 0.6
        animation.period = TimeSpan(duration: 500000)
        return animation
    }()

    private func elementPointerEntered(sender: Any!, args: PointerRoutedEventArgs!) {
        // Scale up to 1.5
        springAnimation.finalValue = Vector3(x: 1.5, y: 1.5, z: 1.5)
        // swiftlint:disable:next force_cast
        let senderAsUElement = sender as! UIElement
        try? senderAsUElement.startAnimation(springAnimation)
    }

    private func elementPointerExited(sender: Any!, args: PointerRoutedEventArgs!) {
        // Scale back down to 1.0
        springAnimation.finalValue = Vector3(x: 1.0, y: 1.0, z: 1.0)
        // swiftlint:disable:next force_cast
        let senderAsUElement = sender as! UIElement
        try? senderAsUElement.startAnimation(springAnimation)
    }
}
