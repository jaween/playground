package com.jaween.androidcameraopengl

import android.graphics.SurfaceTexture
import android.os.Handler
import android.os.Looper
import android.view.TextureView
import java.util.concurrent.Semaphore

/**
 * Forwards TextureView callbacks to a separate thread (to implementor of the RendererInterface).
 */
class TextureViewWrapper(private val renderer: RendererInterface)
    : SurfaceTexture.OnFrameAvailableListener,
      TextureView.SurfaceTextureListener {

    interface EglSurfaceTextureListener {
        fun onSurfaceTextureReady(surfaceTexture: SurfaceTexture)
    }

    private val eglHelper = EglHelper()

    private var renderThread: RenderThread? = null
    private var surfaceTexture: SurfaceTexture? = null
    private var eglSurfaceTexture: SurfaceTexture? = null
    private var listener: EglSurfaceTextureListener? = null
    private var listenersHandler: Handler? = null

    private var surfaceWidth = 0
    private var surfaceHeight = 0

    fun setListener(listener: EglSurfaceTextureListener, handler: Handler) {
        this.listener = listener
        this.listenersHandler = handler
    }

    override fun onSurfaceTextureAvailable(surfaceTexture: SurfaceTexture?,
                                           width: Int,
                                           height: Int) {
        if (renderThread != null) {
            throw IllegalStateException("Already have a context")
        }

        this.surfaceTexture = surfaceTexture
        renderThread = RenderThread()
        renderThread?.start()
        surfaceWidth = width
        surfaceHeight = height
    }

    override fun onSurfaceTextureSizeChanged(surfaceTexture: SurfaceTexture?,
                                             width: Int,
                                             height: Int) {
        if (renderThread != null) {
            throw IllegalStateException("Context not ready")
        }
        surfaceWidth = width
        surfaceHeight = height
        renderThread?.blockingHandler()?.post({
            renderer.onSurfaceChanged(eglSurfaceTexture!!, width, height)
        })
    }

    override fun onSurfaceTextureDestroyed(surfaceTexture: SurfaceTexture?): Boolean {
        if (renderThread == null) {
            return true
        }

        renderThread?.handler?.post({
            Looper.myLooper()?.quit()
        })

        renderThread = null
        return true
    }

    override fun onSurfaceTextureUpdated(surfaceTexture: SurfaceTexture?) {
        // Nothing to do
    }

    override fun onFrameAvailable(surfaceTexture: SurfaceTexture?) {
        renderer.onFrameAvailable(eglSurfaceTexture!!)
        eglHelper.makeCurrent()
        eglHelper.swapBuffers()
    }

    fun configure() {
        eglSurfaceTexture = eglHelper.createSurface(surfaceTexture!!, false)
        renderer.onSurfaceCreated(eglSurfaceTexture!!, surfaceWidth, surfaceHeight)
        eglSurfaceTexture?.setOnFrameAvailableListener(this, renderThread?.handler)

        listenersHandler?.post({
            listener?.onSurfaceTextureReady(eglSurfaceTexture!!)
        })
    }

    fun dispose() {
        renderer.onSurfaceDestroyed(eglSurfaceTexture!!)
        eglHelper.destroySurface()
    }

    private inner class RenderThread : Thread() {

        private val eglContextReadyLock = Semaphore(0)
        var handler: Handler? = null
            private set

        override fun run() {
            Looper.prepare()
            handler = Handler()
            configure()
            eglContextReadyLock.release()
            Looper.loop()
            dispose()
        }

        fun blockingHandler(): Handler? {
            eglContextReadyLock.acquireUninterruptibly()
            eglContextReadyLock.release()
            return handler
        }
    }
}