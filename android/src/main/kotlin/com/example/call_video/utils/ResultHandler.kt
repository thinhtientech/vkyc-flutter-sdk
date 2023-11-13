package com.example.call_video.utils

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ResultHandler(
    private var result: MethodChannel.Result?,
    val call: MethodCall? = null
) {
    init {
        handler.hasMessages(0) // just do it to init handler
    }

    companion object {
        @JvmField
        val handler = Handler(Looper.getMainLooper())
    }

    private var isReplied = false

    fun reply(any: Any?) {
        if (isReplied) {
            return
        }
        isReplied = true
        val result = this.result
        this.result = null
        handler.post {
            try {
                result?.success(any)
            } catch (e: IllegalStateException) {
                // Do nothing
            }
        }
    }

    fun replyError(code: String, message: String? = null, obj: Any? = null) {
        if (isReplied) {
            return
        }
        isReplied = true
        val result = this.result
        this.result = null
        handler.post {
            result?.error(code, message, obj)
        }
    }

    fun notImplemented() {
        if (isReplied) {
            return
        }
        isReplied = true
        val result = this.result
        this.result = null
        handler.post {
            result?.notImplemented()
        }
    }
}
