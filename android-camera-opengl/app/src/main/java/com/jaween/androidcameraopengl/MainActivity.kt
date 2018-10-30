package com.jaween.androidcameraopengl

import android.app.ActivityManager
import android.content.Context
import android.opengl.GLSurfaceView
import android.support.v7.app.AppCompatActivity
import android.os.Bundle

class MainActivity : AppCompatActivity() {

    private val glSurfaceView: GLSurfaceView by lazy {
        findViewById<GLSurfaceView>(R.id.gl_surface_view)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        if (hasGles20()) {
            setupGl()
        }
    }

    override fun onPause() {
        super.onPause()
        glSurfaceView.onPause()
    }

    override fun onResume() {
        super.onResume()
        glSurfaceView.onResume()
    }

    private fun setupGl() {
        val renderer = CustomGlRenderer()
        glSurfaceView.setEGLContextClientVersion(2)
        glSurfaceView.preserveEGLContextOnPause = true
        glSurfaceView.setRenderer(renderer)
    }

    private fun hasGles20(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val deviceConfig = activityManager?.deviceConfigurationInfo
        return deviceConfig.reqGlEsVersion >= 0x20000
    }
}
