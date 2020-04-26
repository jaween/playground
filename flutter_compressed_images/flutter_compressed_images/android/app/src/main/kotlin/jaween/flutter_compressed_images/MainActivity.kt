package jaween.flutter_compressed_images

import android.app.ActivityManager
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val MEM_INFO_CHANNEL = "com.jaween.meminfo"
    private val MEMORY_CHANNEL = "com.jaween.memory"

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        Log.e("MAIN", "############ Trim memory $level")
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, MEMORY_CHANNEL).invokeMethod("onTrimMemory", level);
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        Log.e("MAIN", "########## CONFIGURED")
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEMORY_CHANNEL).invokeMethod("onTrimMemory", -123);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEM_INFO_CHANNEL).setMethodCallHandler {
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
                        "lowMemory" to info.lowMemory,
                        "memoryClass" to activityManager.memoryClass
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
