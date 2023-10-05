package com.adapty.adapty_ui_flutter

import com.adapty.internal.crossplatform.ui.CrossplatformUiHelper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AdaptyUiFlutterPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "flutter.adapty.com/adapty_ui"
    }

    private lateinit var channel: MethodChannel

    private val callHandler: AdaptyUiCallHandler by lazy {
        AdaptyUiCallHandler(CrossplatformUiHelper.shared)
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        CrossplatformUiHelper.init(flutterPluginBinding.applicationContext)
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        callHandler.handleUiEvents(channel)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        callHandler.onMethodCall(call, result)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        onNewActivityPluginBinding(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        onNewActivityPluginBinding(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onNewActivityPluginBinding(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onNewActivityPluginBinding(binding)
    }

    private fun onNewActivityPluginBinding(binding: ActivityPluginBinding?) {
        callHandler.setActivity(binding?.activity)
    }
}
