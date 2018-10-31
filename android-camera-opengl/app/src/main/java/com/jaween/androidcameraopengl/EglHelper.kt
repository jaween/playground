package com.jaween.androidcameraopengl

import android.graphics.SurfaceTexture
import android.opengl.*
import android.util.Log

class EglHelper {

    private var eglContext: EGLContext? = null
    private var eglDisplay: EGLDisplay? = null
    private var eglSurface: EGLSurface? = null

    var eglSurfaceTexture: SurfaceTexture? = null
    private set

    private val eglTextures = IntArray(1)

    fun createSurface(surfaceTexture: SurfaceTexture, isVideo: Boolean): SurfaceTexture? {
        eglDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
        val unusedEglVersion = IntArray(2)
        if (!EGL14.eglInitialize(eglDisplay, unusedEglVersion, 0, unusedEglVersion, 1)) {
            throw RuntimeException("Unable to initialise EGL14")
        }

        val eglContextAttributes = intArrayOf(
                EGL14.EGL_CONTEXT_CLIENT_VERSION, 3,
                EGL14.EGL_NONE
        )

        var eglConfig = createEglConfig(3, isVideo)
        if (eglConfig != null) {
            eglContext = EGL14.eglCreateContext(eglDisplay,eglConfig, EGL14.EGL_NO_CONTEXT, eglContextAttributes, 0)
            if (EGL14.eglGetError() != EGL14.EGL_SUCCESS) {
                Log.e("EglHelper", "Failed to created EGL3 context")
                eglContext = EGL14.EGL_NO_CONTEXT
            }
        }

        if (eglContext == EGL14.EGL_NO_CONTEXT) {
            eglContextAttributes[1] = 2
            eglConfig = createEglConfig(2, isVideo)
            eglContext = EGL14.eglCreateContext(eglDisplay, eglConfig, EGL14.EGL_NO_CONTEXT, eglContextAttributes, 0)
        }

        val values = IntArray(1)
        EGL14.eglQueryContext(eglDisplay, eglContext, EGL14.EGL_CONTEXT_CLIENT_VERSION, values, 0)
        Log.e("EglHelper", "EGLContext created, client version ${values[0]}")

        val surfaceAttributes = intArrayOf(EGL14.EGL_NONE)
        eglSurface = EGL14.eglCreateWindowSurface(eglDisplay, eglConfig, surfaceTexture, surfaceAttributes, 0)
        checkEglError("eglCreateWindowSurface")
        if (!EGL14.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)) {
            throw RuntimeException("eglMakeCurrent failed")
        }

        GLES20.glGenTextures(eglTextures.size, eglTextures, 0)
        GlUtil.checkGlError("Texture bind")
        eglSurfaceTexture = SurfaceTexture(eglTextures[0])

        return eglSurfaceTexture
    }

    fun destroySurface() {
        if (eglDisplay != EGL14.EGL_NO_DISPLAY) {
            Log.d("EglHelper", "Disposing EGL resources")
            var success: Boolean = EGL14.eglTerminate(eglDisplay)
            Log.d("EglHelper", "eglTerminate: $success")
            success = EGL14.eglMakeCurrent(eglDisplay, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
            Log.d("EglHelper", "eglMakeCurrent: $success")
            success = EGL14.eglDestroyContext(eglDisplay, eglContext)
            Log.d("EglHelper", "eglDestroyContext: $success")
            success = EGL14.eglReleaseThread()
            Log.d("EglHelper", "eglReleaseThread: $success")
        }

        eglDisplay = EGL14.EGL_NO_DISPLAY
        eglContext = EGL14.EGL_NO_CONTEXT
        eglSurface = EGL14.EGL_NO_SURFACE
        eglSurfaceTexture = null
    }

    fun createEglConfig(version: Int, isVideo: Boolean): EGLConfig? {
        val renderType = if (version == 3) EGLExt.EGL_OPENGL_ES3_BIT_KHR else EGL14.EGL_OPENGL_ES2_BIT
        val attributeList = intArrayOf(
                EGL14.EGL_RED_SIZE, 8,
                EGL14.EGL_GREEN_SIZE, 8,
                EGL14.EGL_BLUE_SIZE, 8,
                EGL14.EGL_ALPHA_SIZE, 8,
                EGL14.EGL_RENDERABLE_TYPE, renderType,
                EGL14.EGL_NONE, 0,
                EGL14.EGL_NONE
        )

        if (isVideo) {
            attributeList[attributeList.size - 3] = 0x3142 // Magic number
            attributeList[attributeList.size - 2] = 1
        }

        val configs = arrayOfNulls<EGLConfig>(1)
        val numConfigs = intArrayOf(1)
        if (!EGL14.eglChooseConfig(eglDisplay, attributeList, 0, configs, 0, configs.size, numConfigs, 0)) {
            Log.e("EglHelper", "Unable to find RGB8888 $version EGLConfig")
            return null
        }

        return configs[0]
    }

    fun makeCurrent(): Boolean {
        val success = EGL14.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)
        if (!success) {
            Log.e("EglHelper", "eglMakeCurrent failed")
        }
        return success
    }

    fun swapBuffers(): Boolean {
        val success = EGL14.eglSwapBuffers(eglDisplay, eglSurface)
        if (!success) {
            Log.e("EglHelper", "eglSwapBuffers failed")
        }
        return success
    }

    companion object {
        fun checkEglError(message: String) {
            val error = EGL14.eglGetError()
            if (error != EGL14.EGL_SUCCESS) {
                throw RuntimeException("$message: EGL error 0x${error.toString(16)}")
            }
        }
    }

}