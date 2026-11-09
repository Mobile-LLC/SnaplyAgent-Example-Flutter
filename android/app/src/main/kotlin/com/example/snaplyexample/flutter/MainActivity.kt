package com.example.snaplyexample.flutter

import android.content.pm.ApplicationInfo
import android.os.Bundle
import com.snaply.agent.Snaply
import com.snaply.agent.SnaplyEnvironment
import com.snaply.agent.SnaplyUser
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode

/**
 * Replace with your own key from the Snaply console (Products → your product → API key).
 *
 * It is not a secret. It identifies the workspace, ships inside every copy of your app, and is
 * checked server-side against your product's allowed package name.
 */
private const val SnaplyKey = "snap_live_REPLACE_WITH_YOUR_KEY"

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startSnaply()
    }

    /**
     * Required for captures. The SDK copies this app's window, and Flutter's default render mode
     * draws into a separate SurfaceView that is not part of it: the agent would receive a blank
     * screen (measured 2026-11-10, SDK 2.38.0). A TextureView is drawn inside the window.
     */
    override fun getRenderMode(): RenderMode = RenderMode.texture

    /** The Android side of the integration: the native SDK, started once. */
    private fun startSnaply() {
        var key = SnaplyKey
        var environment: SnaplyEnvironment = SnaplyEnvironment.Live
        if (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0) {
            // Development only: the launch intent's `snaplyKey` / `snaplyHost` extras point a debug
            // build at another key, or at a backend running on your own machine.
            intent.getStringExtra("snaplyKey")?.let { key = it }
            intent.getStringExtra("snaplyHost")?.let { environment = SnaplyEnvironment.Custom(it) }
        }

        // `user` is optional — without it the device stays anonymous and support finds it by the
        // support code. Call Snaply.identify(id, name, phone) when someone signs in later.
        Snaply.init(
            context = this,
            key = key,
            environment = environment,
            user = SnaplyUser(id = "usr_20481", name = "Maya Kowalski"),
        )
    }
}
