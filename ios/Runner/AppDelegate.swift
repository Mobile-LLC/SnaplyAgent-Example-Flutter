import Flutter
import SnaplyAgent
import UIKit

/// Replace with your own key from the Snaply console (Products → your product → API key).
///
/// It is not a secret. It identifies the workspace, ships inside every copy of your app, and is
/// checked server-side against your product's allowed bundle id.
private let snaplyKey = "snap_live_REPLACE_WITH_YOUR_KEY"

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    startSnaply()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  /// The iOS side of the integration: the native SDK, started once.
  private func startSnaply() {
    var key = snaplyKey
    var environment = SnaplyEnvironment.live
    // Development only: SNAPLY_KEY / SNAPLY_HOST in the launch environment (an Xcode scheme, or
    // `simctl launch`) point the app at another key, or at a backend running on your own machine.
    // Not behind `#if DEBUG`: Flutter's Runner target does not define DEBUG for Swift.
    let launch = ProcessInfo.processInfo.environment
    if let value = launch["SNAPLY_KEY"] { key = value }
    if let host = launch["SNAPLY_HOST"].flatMap({ URL(string: $0) }) { environment = .custom(host) }

    // `user` is optional — without it the device stays anonymous and support finds it by the
    // support code. Call Snaply.identify(id:name:phone:) when someone signs in later.
    Snaply.configure(
      key: key,
      environment: environment,
      user: SnaplyUser(id: "usr_20481", name: "Maya Kowalski")
    ) { error in
      if let error { NSLog("Snaply: could not connect — %@", error.localizedDescription) }
    }
  }
}
