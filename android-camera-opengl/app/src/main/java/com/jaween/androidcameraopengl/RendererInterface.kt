package com.jaween.androidcameraopengl

import android.graphics.SurfaceTexture

interface RendererInterface {
    fun onSurfaceCreated(eglSurfaceTexture: SurfaceTexture, width: Int, height: Int)
    fun onSurfaceChanged(eglSurfaceTexture: SurfaceTexture, width: Int, height: Int)
    fun onSurfaceDestroyed(eglSurfaceTexture: SurfaceTexture)
    fun onFrameAvailable(eglSurfaceTexture: SurfaceTexture)
}