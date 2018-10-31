package com.jaween.androidcameraopengl

import android.Manifest
import android.annotation.SuppressLint
import android.app.ActivityManager
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.SurfaceTexture
import android.hardware.camera2.CameraCaptureSession
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CaptureRequest
import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.view.Surface
import android.view.TextureView

class MainActivity : AppCompatActivity() {

    private val requestCode = 1

    private val videoPermissions = arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO)

    private val textureView: TextureView by lazy {
        findViewById<TextureView>(R.id.texture_view)
    }

    private val textureViewWrapper: TextureViewWrapper by lazy {
        val renderer = CustomGlRenderer()
        TextureViewWrapper(renderer)
    }

    private val cameraManager: CameraManager by lazy {
        getSystemService(Context.CAMERA_SERVICE) as CameraManager
    }

    private var cameraDevice: CameraDevice? = null
    private var captureSession: CameraCaptureSession? = null
    private var canOpenCamera = false

    private var surface: Surface? = null
    private var surfaceTexture: SurfaceTexture? = null

    private lateinit var backgroundThread: HandlerThread
    private lateinit var backgroundHandler: Handler

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.test_main)
    }

    override fun onResume() {
        super.onResume()

        if (hasGles20()) {
            if (!hasAllPermissionsGranted(videoPermissions)) {
                ActivityCompat.requestPermissions(this, videoPermissions, requestCode)
            } else {
                canOpenCamera = true
                setupGl()
            }
        }
    }

    override fun onPause() {
        super.onPause()
        closeCamera()
        canOpenCamera = false

        try {
            backgroundThread.interrupt()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun setupGl(){
        textureViewWrapper.setListener(
                object : TextureViewWrapper.EglSurfaceTextureListener {
            override fun onSurfaceTextureReady(surfaceTexture: SurfaceTexture) {
                this@MainActivity.surfaceTexture = surfaceTexture
                openCamera()
            }
        }, Handler(Looper.getMainLooper()))

        backgroundThread = HandlerThread("bg")
        backgroundThread.start()
        backgroundHandler = Handler(backgroundThread.looper)

        textureView.surfaceTextureListener = surfaceTextureListener
    }

    @SuppressLint("MissingPermission")
    private fun openCamera() {
        if (!canOpenCamera ||
                !textureView.isAvailable ||
                surfaceTexture == null ||
                cameraDevice != null) {
            Log.e("MainActivity", "Failed to open camera")
            return
        }

        cameraManager.openCamera("0", object: CameraDevice.StateCallback() {
            override fun onOpened(camera: CameraDevice?) {
                Log.d("MainActivity", "Opened camera")
                cameraDevice = camera
                surface = Surface(surfaceTexture)
                surfaceTexture?.setDefaultBufferSize(textureView.width, textureView.height)
                val request = cameraDevice?.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW)
                request?.addTarget(surface)

                cameraDevice?.createCaptureSession(listOf(surface), object : CameraCaptureSession.StateCallback() {
                    override fun onConfigured(session: CameraCaptureSession?) {
                        request?.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO)
                        request?.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
                        request?.set(CaptureRequest.CONTROL_AE_ANTIBANDING_MODE, CaptureRequest.CONTROL_AE_ANTIBANDING_MODE_AUTO)
                        session?.setRepeatingRequest(request?.build(), null, null)
                        captureSession = session
                    }

                    override fun onConfigureFailed(session: CameraCaptureSession?) {
                        error("Camera session onConfigure failed")
                    }
                }, null)
            }

            override fun onDisconnected(p0: CameraDevice?) {
                // Nothing to do
            }

            override fun onError(camera: CameraDevice?, error: Int) {
                error("Failed to open camera")
            }
        }, null)
    }

    private fun closeCamera() {
        captureSession?.close()
        captureSession = null
        cameraDevice?.close()
        cameraDevice = null
        surfaceTexture = null
        Log.d("MainActivity", "Closed camera if it was open")
    }


    private fun hasGles20(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val deviceConfig = activityManager.deviceConfigurationInfo
        return deviceConfig.reqGlEsVersion >= 0x20000
    }

    override fun onRequestPermissionsResult(requestCode: Int,
                                            permissions: Array<out String>,
                                            grantResults: IntArray) {
        when (requestCode) {
            this.requestCode -> {
                if (grantResults.size == videoPermissions.size) {
                    val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
                    Log.i("MainActivity", "All permissions granted? $allGranted")
                }
            }
            else -> super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }

    private fun hasAllPermissionsGranted(permissions: Array<String>) =
            permissions.none {
                ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
            }

    private val surfaceTextureListener = object : TextureView.SurfaceTextureListener {
        override fun onSurfaceTextureAvailable(surfaceTexture: SurfaceTexture?,
                                               width: Int,
                                               height: Int) {
            textureViewWrapper.onSurfaceTextureAvailable(surfaceTexture, width, height)
        }

        override fun onSurfaceTextureSizeChanged(surfaceTexture: SurfaceTexture?,
                                                 width: Int,
                                                 height: Int) {
            textureViewWrapper.onSurfaceTextureSizeChanged(surfaceTexture, width, height)
        }

        override fun onSurfaceTextureUpdated(surfaceTexture: SurfaceTexture?) {
            textureViewWrapper.onSurfaceTextureUpdated(surfaceTexture)
        }

        override fun onSurfaceTextureDestroyed(surfaceTexture: SurfaceTexture?): Boolean {
            textureViewWrapper.onSurfaceTextureDestroyed(surfaceTexture)
            return true
        }
    }
}
