# Snaply Agent — Flutter example

A runnable Flutter app with the Snaply Agent SDKs inside, and an honest account of what works.
There is no Flutter package yet: the app starts the **native iOS and Android SDKs as they are**
from its two native entry points.

Flutter paints its whole screen itself into one native view. The native SDKs capture that view,
but they find no text fields in it — so **most of what hides a field in a native app does not
reach a Flutter widget today**. Read "What was measured" before using this in an app that shows
anything sensitive.

The integration is two functions:

- iOS — [`ios/Runner/AppDelegate.swift`](ios/Runner/AppDelegate.swift)
- Android — [`android/app/src/main/kotlin/com/example/snaplyexample/flutter/MainActivity.kt`](android/app/src/main/kotlin/com/example/snaplyexample/flutter/MainActivity.kt)

[`lib/main.dart`](lib/main.dart) is the screen the checks were run against.

## Run it

1. Replace the placeholder key in both native files:

   ```
   snap_live_REPLACE_WITH_YOUR_KEY
   ```

   Get yours from the Snaply console → **Products → your product → API key**. An iOS product and
   an Android product each have their own key.

2. Add the app's identifier to each product's allowed list, or registration is refused. This
   example uses `com.example.snaplyexample.flutter` on both platforms.
3. `flutter run`.
4. Open the console, find the device, and request a screenshot. The consent prompt appears on the
   phone; nothing is captured until it is allowed.

## Adding the SDK to your own Flutter app

**iOS.** Open `ios/Runner.xcworkspace`, *File → Add Package Dependencies…*, and add
`https://github.com/Mobile-LLC/SnaplyAgent-SDK-iOS` to the Runner target. Raise the deployment
target to iOS 15, the SDK's floor (Flutter's template says 13). Then, in `AppDelegate.swift`:

```swift
import SnaplyAgent

Snaply.configure(key: "snap_live_…")
```

**Android.** One dependency in `android/app/build.gradle.kts`, from Maven Central:

```kotlin
dependencies {
    implementation("com.snaplyagent:agent:2.38.0")
}
```

Then, in `MainActivity`:

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    Snaply.init(context = this, key = "snap_live_…")
}

// Required: without it the agent receives a blank screen.
override fun getRenderMode(): RenderMode = RenderMode.texture
```

Flutter's default render mode on Android draws into a separate `SurfaceView`, which is not part of
the window the SDK copies. `RenderMode.texture` draws inside the window; Flutter's documentation
describes it as somewhat slower than the default.

## What was measured

On 2026-11-10, with this app as committed: Flutter 3.44.8, the iOS SDK 2.47.0 on an iOS 18.6
simulator, the Android SDK 2.38.0 on an API 34 emulator, against a local Snaply backend.

| | iOS | Android |
|---|---|---|
| Registers and comes online | ✓ | ✓ |
| Screenshot after consent, screen content correct | ✓ | ✓ with `RenderMode.texture`; **blank** in the default mode |
| Password field (`obscureText`) hidden on its own | ✗ | ✗ |
| In-code mark (`snaply-redact` as a `Semantics` identifier) | ✗ | ✗ |
| Dashboard rule by identifier (`Semantics(identifier:)`) | ✓ | ✗ |
| Dashboard rule by text (`Semantics(label:)`, hint) | ✓ | ✗ |
| Live view | ✓ | ✓ with `RenderMode.texture` |
| Remote control — tap a button | ✓ | ✓ |
| Remote control — type into a field | ✗ | ✗ |

In words:

- **Nothing is hidden on Android.** A password, a card number, anything on screen reaches the
  agent as it is.
- **On iOS only the dashboard's rules hide a field** (Products → Hidden fields): a rule by
  identifier matches a widget wrapped in `Semantics(identifier: 'ibanField', …)`, and a rule by
  text matches its semantics label. A password field is not hidden on its own, and there is no
  in-code mark.
- A text rule hides every node whose label contains the text, captions included.

Not measured: a physical iPhone (only a simulator was used; whether a snapshot of Flutter's Metal
layer behaves the same on a device is unproven) and Flutter for the web.

What the agent received — iOS (the two dashboard rules hide the IBAN and the passport), Android in
`RenderMode.texture`, and Android in Flutter's default render mode:

| iOS | Android | Android, default render mode |
|---|---|---|
| ![The capture on iOS](docs/capture-ios.png) | ![The capture on Android](docs/capture-android.png) | ![A blank capture](docs/capture-android-default-render-mode.png) |

## What is not here yet

- A Dart API: `identify`, `reset` and `showSupportCode` are native calls.
- A way to hide a widget from Dart, on both platforms, and automatic hiding of `obscureText`
  fields.
- Capture in Flutter's default Android render mode, and typing by remote control.

## Pointing the app at another backend

The app reads an override at launch, so it can talk to a backend on your own machine:

- iOS — the launch environment: `SNAPLY_KEY`, `SNAPLY_HOST` (an Xcode scheme, or
  `SIMCTL_CHILD_SNAPLY_HOST=http://localhost:5100 xcrun simctl launch …`). It is not behind
  `#if DEBUG`: Flutter's Runner target does not define `DEBUG` for Swift.
- Android, debuggable builds — launch intent extras:
  `--es snaplyKey … --es snaplyHost http://10.0.2.2:5100`.

Plain `http` is accepted for the machine's own loopback only; the debug manifest and
`Info.plist` allow exactly that.

## Docs

<https://snaplyagent.com/docs>
