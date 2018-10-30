package com.jaween.androidcameraopengl

import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.opengl.Matrix
import android.os.SystemClock
import android.util.Log
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10


class CustomGlRenderer : GLSurfaceView.Renderer {

    private val bytesPerFloat = 4

    private val modelMatrix = FloatArray(16)
    private val viewMatrix = FloatArray(16)
    private val projectionMatrix = FloatArray(16)
    private val mvpMatrix = FloatArray(16)

    private val strideBytes = 7 * bytesPerFloat
    private val positionOffset = 0
    private val positionDataSize = 3
    private val colorOffset = 3
    private val colorDataSize = 4

    private var shaderProgram: Int = 0
    private var mvpMatrixHandle: Int = 0
    private var positionHandle: Int = 0
    private var colorHandle: Int = 0

    private var vbo: FloatBuffer? = null

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        Log.e("CustomGlRenderer", "Surface created")
        setupVertices()
        setupCamera()
        setupShader()
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        Log.e("CustomGlRenderer", "Surface changed $width x $height")

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
    ;
    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClearColor(1f, 1f, 1f, 1f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)

        val time = SystemClock.elapsedRealtime()
        val degrees = (60 * time / 1000.0f) % 360.0f
        Matrix.setIdentityM(modelMatrix, 0)
        Matrix.rotateM(modelMatrix, 0, degrees, 0.0f, 1.0f, 0.0f)

        GLES20.glUseProgram(shaderProgram)
        drawTriangle(vbo!!)
    }

    private fun setupVertices() {
        val vertices = arrayOf(
                0.0f,  0.5f, 0.0f,
                1.0f, 0.0f, 0.0f, 1.0f,

                0.5f, -0.5f, 0.0f,
                0.0f, 0.0f, 1.0f, 1.0f,

                -0.5f, -0.5f, 0.0f,
                0.0f, 1.0f, 0.0f, 1.0f
        )

        vbo = ByteBuffer.allocateDirect(vertices.size * bytesPerFloat)
                .order(ByteOrder.nativeOrder()).asFloatBuffer()
        vertices.forEach { vbo?.put(it) }
    }

    private fun setupCamera() {
        val eyeX = 0.0f
        val eyeY = 0.0f
        val eyeZ = 1.5f
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
        mvpMatrixHandle = GLES20.glGetUniformLocation(shaderProgram, "uMVPMatrix")
        positionHandle = GLES20.glGetAttribLocation(shaderProgram, "aPosition")
        colorHandle  = GLES20.glGetAttribLocation(shaderProgram, "aColor")
    }

    private fun drawTriangle(buffer: FloatBuffer) {
        buffer.position(positionOffset)
        GLES20.glVertexAttribPointer(
                positionHandle,
                positionDataSize,
                GLES20.GL_FLOAT,
                false,
                strideBytes,
                buffer)
        GLES20.glEnableVertexAttribArray(positionHandle)

        buffer.position(colorOffset)
        GLES20.glVertexAttribPointer(
                colorHandle,
                colorDataSize,
                GLES20.GL_FLOAT,
                false,
                strideBytes,
                buffer)
        GLES20.glEnableVertexAttribArray(colorHandle)

        Matrix.multiplyMM(mvpMatrix, 0, viewMatrix, 0, modelMatrix, 0)
        Matrix.multiplyMM(mvpMatrix, 0, projectionMatrix, 0, mvpMatrix, 0)
        GLES20.glUniformMatrix4fv(mvpMatrixHandle, 1, false, mvpMatrix, 0)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, 3)
    }

}