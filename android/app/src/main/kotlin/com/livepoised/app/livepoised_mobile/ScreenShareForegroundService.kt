package com.livepoised.app.livepoised_mobile

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * Minimal foreground service satisfying Android 14's hard requirement that
 * MediaProjection screen capture only starts while a foregroundServiceType
 * "mediaProjection" service is already running. flutter_webrtc 1.6.0 (the
 * version livekit_client pins) never starts one itself — this was missing
 * entirely, and screen share was throwing a SecurityException at the
 * native/platform layer (uncatchable from Dart's try/catch) that killed the
 * whole app process the instant capture was requested.
 */
class ScreenShareForegroundService : Service() {
    companion object {
        private const val CHANNEL_ID = "screen_share_channel"
        private const val NOTIFICATION_ID = 6543
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Screen Sharing",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shown while you're sharing your screen on a call"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Screen sharing active")
            .setContentText("Your screen is being shared on the call")
            .setSmallIcon(android.R.drawable.ic_menu_share)
            .setOngoing(true)
            .build()
    }
}
