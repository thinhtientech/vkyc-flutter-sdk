package com.example.call_video.core

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.provider.Settings
import androidx.core.content.ContextCompat.startActivity
import com.example.call_video.config.Methods
import com.example.call_video.utils.ResultHandler
import com.fis.ekyc.nfc.build_in.model.ResultCode
import com.fis.nfc.sdk.nfc.stepNfc.CustomSdk
import com.fis.nfc.sdk.nfc.stepNfc.NFCListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

class CallVideoPlugin(
    private val context: Context,
    private var activity: Activity?
) : MethodChannel.MethodCallHandler {
    companion object {
        private const val poolSize = 8
        private val threadPool: ThreadPoolExecutor = ThreadPoolExecutor(
            poolSize,
            Int.MAX_VALUE,
            1,
            TimeUnit.MINUTES,
            LinkedBlockingQueue()
        )

        fun runOnBackground(runnable: () -> Unit) {
            threadPool.execute(runnable)
        }
    }

    @SuppressLint("SuspiciousIndentation")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val resultHandler = ResultHandler(result, call)

        onHandlePermissionResult(call,resultHandler)
    }

    private fun onHandlePermissionResult(
        call: MethodCall,
        resultHandler: ResultHandler,
    ) {
        runOnBackground {
            try {
                handleMethodResult(call, resultHandler)
            } catch (e: Exception) {
                val method = call.method
                val params = call.arguments
                resultHandler.replyError(
                    "The $method method has an error: ${e.message}",
                    e.stackTraceToString(),
                    params
                )
            }
        }
    }

    private fun handleMethodResult(
        call: MethodCall,
        resultHandler: ResultHandler
    ) {
        when (call.method) {
            Methods.startNFC -> {
                val argument = (call.arguments as MutableMap<*, *>)

                val id = argument["id"] as String

                CustomSdk.apply {
                    idCard = id
                    //Listen for sdk response
                    nfcListener = object : NFCListener {
                        override fun onError(errorCode: ResultCode) {
                            resultHandler.reply(errorCode.toString())
                        }

                        override fun onSuccess(result: String) {
                            resultHandler.reply(result)
                        }
                    }
                }

                //Check for NFC available before start listening NFC intent
                when (val error = CustomSdk.checkNFCAvailable(activity!!)){
                    ResultCode.NFC_IS_OFF -> {
                        enableNfc()
                    }

                    ResultCode.NFC_IS_AVAILABLE -> {
                        //Start listening NFC intent
                        CustomSdk.start(context)
                    }
                    else -> {
                        resultHandler.reply(error.toString())
                    }
                }
            }

            else -> resultHandler.notImplemented()
        }
    }

    fun bindActivity(activity: Activity?) {
        this.activity = activity
    }

    private fun enableNfc() {
        val intent = Intent(Settings.ACTION_NFC_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(context,intent,null)
    }
}