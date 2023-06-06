package com.unlocker

import android.annotation.SuppressLint
import android.content.Intent
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.safetransportset.safe.MainActivity
import java.util.*

public class BkgndStarterService : FirebaseMessagingService() {
    private val TAG = "KeyguardUnlockerFCM"

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        Log.w(TAG, ">>>>>>>>>>>>>>>>> received broadcast");

        val data = remoteMessage.data
        if (!data.containsKey(KEY_PAYLOAD_MESSAGE_TYPE))
            return;

        when (data[KEY_PAYLOAD_MESSAGE_TYPE]) {
            MESSAGE_TYPE_TO_DRIVER_SHARED_RIDE_CUSTOMER_REQUESTED -> {
                if (!isApplicationForeground(this)) {
                    val intent = Intent(this, MainActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                }
            }
        }
    }
}