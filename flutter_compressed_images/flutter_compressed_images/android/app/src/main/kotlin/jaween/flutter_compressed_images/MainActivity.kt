package jaween.flutter_compressed_images

import android.app.ActivityManager
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.jaween.test"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "getMemoryInfo" -> {
                    val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val info = ActivityManager.MemoryInfo().also {
                        memoryInfo -> activityManager.getMemoryInfo(memoryInfo)
                    }
                    val data = mapOf(
                        "available" to info.availMem,
                        "threshold" to info.threshold,
                        "total" to info.totalMem,
                        "lowMemory" to info.lowMemory
                    )
                    result.success(data)
                }
                else -> {
                    Log.e("Main", "No such method");
                }
            }
        }
    }
}
