package com.jaween.androidcameraopengl

import android.graphics.SurfaceTexture
import android.opengl.GLES20
import android.opengl.Matrix
import android.os.SystemClock
import android.util.Log
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import java.nio.ShortBuffer


class CustomGlRenderer : RendererInterface {

    private val bytesPerFloat = 4
    private val bytesPerShort = 2

    private val modelMatrix = FloatArray(16)
    private val viewMatrix = FloatArray(16)
    private val projectionMatrix = FloatArray(16)
    private val mvpMatrix = FloatArray(16)

    private val strideBytes = 9 * bytesPerFloat
    private val positionValuesPerStride = 3
    private val colorValuesPerStride = 4
    private val texCoordValuesPerStride = 2

    private var shaderProgram: Int = 0
    private var mvpMatrixHandle: Int = 0
    private var positionHandle: Int = 0
    private var colorHandle: Int = 0
    private var texCoordHandle: Int = 0
    private var textureHandle: Int = 0

    private var vbo: Int = 0
    private var ibo: Int = 0

    private var surfaceWidth = 0
    private var surfaceHeight = 0

    override fun onSurfaceCreated(eglSurfaceTexture: SurfaceTexture, width: Int, height: Int) {
        Log.e("CustomGlRenderer", "Surface created")

        surfaceWidth = width
        surfaceHeight = height

        setupVertices()
        setupView()
        setupShader()
    }

    override fun onSurfaceChanged(eglSurfaceTexture: SurfaceTexture, width: Int, height: Int) {
        Log.e("CustomGlRenderer", "Surface changed $width x $height")

        surfaceWidth = width
        surfaceHeight = height

        GLES20.glViewport(0, 0, width, height)
        val ratio = width.toFloat() / height
        Matrix.frustumM(projectionMatrix,
                0,
                -ratio,
                ratio,
                -1.0f,
                1.0f,
                1.0f,
                10.0f)
    }

    override fun onFrameAvailable(eglSurfaceTexture: SurfaceTexture) {
        // Update view
        val time = SystemClock.elapsedRealtime()
        val degrees = (60 * time / 1000.0f) % 360.0f
        Matrix.setIdentityM(modelMatrix, 0)
        Matrix.rotateM(modelMatrix, 0, degrees, 0.0f, 1.0f, 0.0f)

        // Updates the texture object with content from the stream
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        eglSurfaceTexture.updateTexImage()

        draw()
    }

    private fun setupVertices() {
        val vertexData = floatArrayOf(
                // X Y Z
                // R G B A
                // U V
                // Bottom left
                -1.0f, -1.0f, 0.0f,
                1.0f, 0.0f, 0.0f, 1.0f,
                0.0f, 1.0f,

                // Top left
                -1.0f, 1.0f, 0.0f,
                0.0f, 0.0f, 1.0f, 1.0f,
                0.0f, 0.0f,

                // Top right
                1.0f, 1.0f, 0.0f,
                0.0f, 1.0f, 0.0f, 1.0f,
                1.0f, 0.0f,

                // Bottom right
                1.0f, -1.0f, 0.0f,
                0.0f, 1.0f, 0.0f, 1.0f,
                1.0f, 1.0f
        )
        val vertexBuffer: FloatBuffer = ByteBuffer
                .allocateDirect(vertexData.size * bytesPerFloat)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer()
        vertexBuffer.put(vertexData).position(0)

        val indexData = shortArrayOf(
                0, 1, 3,
                1, 2, 3
        )
        val indexBuffer: ShortBuffer = ByteBuffer
                .allocateDirect(indexData.size * bytesPerShort)
                .order(ByteOrder.nativeOrder())
                .asShortBuffer()
        indexBuffer.put(indexData).position(0)

        val vboHandleArray = IntArray(1)
        val iboHandleArray = IntArray(1)
        GLES20.glGenBuffers(1, vboHandleArray, 0)
        GLES20.glGenBuffers(1, iboHandleArray, 0)
        vbo = vboHandleArray[0]
        ibo = iboHandleArray[0]
        if (vbo <= 0 || ibo <= 0) {
            Log.e("CustomGlRenderer", "Error creating vertex buffers")
            return
        }

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, vbo)
        GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, vertexBuffer.capacity() * bytesPerFloat, vertexBuffer, GLES20.GL_STATIC_DRAW)

        GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, ibo)
        GLES20.glBufferData(GLES20.GL_ELEMENT_ARRAY_BUFFER, indexBuffer.capacity() * bytesPerShort, indexBuffer, GLES20.GL_STATIC_DRAW)

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0)
        GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, 0)
    }

    private fun setupView() {
        val eyeX = 0.0f
        val eyeY = 0.0f
        val eyeZ = 2.0f
        val lookX = 0.0f
        val lookY = 0.0f
        val lookZ = -5.0f
        val upX = 0.0f
        val upY = 1.0f
        val upZ = 0.0f

        Matrix.setLookAtM(viewMatrix, 0,
                eyeX, eyeY, eyeZ,
                lookX, lookY, lookZ,
                upX, upY, upZ)
    }

    private fun setupShader() {
        shaderProgram = ShaderUtil.createShader()

        GLES20.glUseProgram(shaderProgram)
        mvpMatrixHandle = GLES20.glGetUniformLocation(shaderProgram, "uMVPMatrix")
        textureHandle = GLES20.glGetUniformLocation(shaderProgram, "uTexture")

        positionHandle = GLES20.glGetAttribLocation(shaderProgram, "aPosition")
        colorHandle  = GLES20.glGetAttribLocation(shaderProgram, "aColor")
        texCoordHandle = GLES20.glGetAttribLocation(shaderProgram, "aTexCoord")
        GlUtil.checkGlError("getLocations")
    }

    private fun draw() {
        GLES20.glClearColor(1f, 1f, 1f, 1f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)

        GLES20.glUseProgram(shaderProgram)
        GLES20.glViewport(0, 0, surfaceWidth, surfaceHeight)

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, vbo)

        GLES20.glVertexAttribPointer(
                positionHandle,
                positionValuesPerStride,
                GLES20.GL_FLOAT,
                false,
                strideBytes,
                0)
        GLES20.glEnableVertexAttribArray(positionHandle)

        GLES20.glVertexAttribPointer(
                colorHandle,
                colorValuesPerStride,
                GLES20.GL_FLOAT,
                false,
                strideBytes,
                positionValuesPerStride * bytesPerFloat)
        GLES20.glEnableVertexAttribArray(colorHandle)

        GLES20.glVertexAttribPointer(
                texCoordHandle,
                texCoordValuesPerStride,
                GLES20.GL_FLOAT,
                false,
                strideBytes,
                (positionValuesPerStride + colorValuesPerStride) * bytesPerFloat)
        GLES20.glEnableVertexAttribArray(texCoordHandle)

        Matrix.multiplyMM(mvpMatrix, 0, viewMatrix, 0, modelMatrix, 0)
        Matrix.multiplyMM(mvpMatrix, 0, projectionMatrix, 0, mvpMatrix, 0)
        GLES20.glUniformMatrix4fv(mvpMatrixHandle, 1, false, mvpMatrix, 0)

        GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, ibo)
        GLES20.glDrawElements(GLES20.GL_TRIANGLES, 6, GLES20.GL_UNSIGNED_SHORT, 0)

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0)
        GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, 0)
    }

    override fun onSurfaceDestroyed(eglSurfaceTexture: SurfaceTexture) {
        // Nothing to do
    }
}