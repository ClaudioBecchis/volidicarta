package it.polariscore.bookshelf

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Riceve l'intent MY_PACKAGE_REPLACED dopo che l'APK è stato
 * aggiornato dal sistema. Rilancia automaticamente l'app.
 */
class UpdateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                launchIntent.addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
                )
                context.startActivity(launchIntent)
            }
        }
    }
}
