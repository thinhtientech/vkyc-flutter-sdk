package com.example.call_video

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import com.example.call_video.core.CallVideoPlugin as InnerCallVideoPlugin

class CallVideoPlugin: FlutterPlugin, ActivityAware {
    private var plugin: InnerCallVideoPlugin? = null
//    private val nfc : NfcManager = NfcManager()

    private var bindings: ActivityPluginBinding? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//        val pendingIntent = getPendingInter(binding.applicationContext)
        plugin = InnerCallVideoPlugin(
            binding.applicationContext,
            null
        ).apply {
            register(this, binding.binaryMessenger)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        plugin = null
    }

    override fun onDetachedFromActivity() {
        // Release the Activity reference on detached.
        plugin?.bindActivity(null)
        bindings = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityAttached(binding)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityAttached(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        plugin?.bindActivity(null)
    }

    private fun activityAttached(binding: ActivityPluginBinding) {
        binding.apply {
            this@CallVideoPlugin.bindings = this
            plugin?.bindActivity(activity)
        }
    }

    private fun register(plugin: InnerCallVideoPlugin, messenger: BinaryMessenger) {
        MethodChannel(messenger, "com.example/call_video").apply {
            setMethodCallHandler(plugin)
        }
    }

    private fun getPendingInter(context: Context) : PendingIntent {
        val intent = Intent(context, this.javaClass)
        intent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP

        return PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_MUTABLE)
    }
}