package com.livepoised.app.livepoised_mobile

import android.app.AppOpsManager
import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.util.Rational
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.livepoised.app/pip"
    private var methodChannel: MethodChannel? = null
    private var isCallActive = false

    private val actionEndCall = "com.livepoised.app.PIP_ACTION_END_CALL"
    private var pipActionReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isPipSupported" -> result.success(isPipSupported())
                "isPipPermissionEnabled" -> result.success(isPipPermissionEnabled())
                "openPipSettings" -> {
                    openPipSettings()
                    result.success(null)
                }
                "setCallActive" -> {
                    isCallActive = call.arguments as? Boolean ?: false
                    result.success(null)
                }
                "enterPip" -> {
                    result.success(enterPip())
                }
                "startScreenShareService" -> {
                    try {
                        ContextCompat.startForegroundService(
                            this,
                            Intent(this, ScreenShareForegroundService::class.java)
                        )
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "stopScreenShareService" -> {
                    stopService(Intent(this, ScreenShareForegroundService::class.java))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        pipActionReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action == actionEndCall) {
                    methodChannel?.invokeMethod("onPipAction", "end_call")
                }
            }
        }
        val filter = IntentFilter(actionEndCall)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(pipActionReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(pipActionReceiver, filter)
        }
    }

    override fun onDestroy() {
        pipActionReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (e: Exception) {
                // already unregistered
            }
        }
        super.onDestroy()
    }

    private fun isPipSupported(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            packageManager.hasSystemFeature(android.content.pm.PackageManager.FEATURE_PICTURE_IN_PICTURE)
    }

    private fun isPipPermissionEnabled(): Boolean {
        if (!isPipSupported()) return false
        val appOps = getSystemService(APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_PICTURE_IN_PICTURE,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openPipSettings() {
        val intent = Intent("android.settings.PICTURE_IN_PICTURE_SETTINGS", Uri.parse("package:$packageName"))
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(intent)
        } catch (e: Exception) {
            startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")))
        }
    }

    private fun buildPipActions(): ArrayList<RemoteAction> {
        val pendingIntentFlags = PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        val endCallIntent = PendingIntent.getBroadcast(
            this,
            1,
            Intent(actionEndCall).setPackage(packageName),
            pendingIntentFlags
        )
        val endCallAction = RemoteAction(
            Icon.createWithResource(this, android.R.drawable.ic_menu_close_clear_cancel),
            "End Call",
            "End the call",
            endCallIntent
        )
        return arrayListOf(endCallAction)
    }

    private fun enterPip(): Boolean {
        if (!isPipSupported()) return false
        return try {
            val params = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(3, 4))
                .setActions(buildPipActions())
                .build()
            enterPictureInPictureMode(params)
            true
        } catch (e: Exception) {
            false
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // Only auto-enter PiP if a call is active AND user was actively interacting with the app (has window focus)
        // This prevents PiP from launching during background-to-foreground transition when accepting from notification.
        val willEnter = isCallActive && isPipSupported() && hasWindowFocus()
        Log.d("LivePoisedPip", "onUserLeaveHint: isCallActive=$isCallActive hasWindowFocus=${hasWindowFocus()} -> willEnterPip=$willEnter")
        if (willEnter) {
            enterPip()
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        Log.d("LivePoisedPip", "onPictureInPictureModeChanged: isInPictureInPictureMode=$isInPictureInPictureMode")
        run {
            // invalidate()/requestLayout() alone (the previous attempt here)
            // only asks Android to repaint the EXISTING SurfaceView surface —
            // confirmed via live device logs that this callback does fire
            // correctly on both directions, but the black screen persisted
            // anyway, meaning the surface itself (not just its last-painted
            // frame) is going stale across the PiP resize. Briefly toggling
            // the decor view's visibility forces Android to fully tear down
            // and recreate the surface on the next layout pass instead of
            // just repainting whatever the old one had — a stronger, widely
            // reported-working fix for this exact Flutter-PiP class of bug.
            // Doesn't touch which rendering surface Flutter uses (TextureView
            // was tried earlier and reverted: it fixes this but breaks
            // MediaProjection screen-capture, an unacceptable trade).
            val decorView = window.decorView
            decorView.visibility = android.view.View.GONE
            decorView.post {
                decorView.visibility = android.view.View.VISIBLE
                decorView.invalidate()
                decorView.requestLayout()
            }
        }
        methodChannel?.invokeMethod("onPipModeChanged", isInPictureInPictureMode)
    }
}
