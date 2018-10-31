package com.jaween.androidcameraopengl

import android.opengl.GLES20
import android.util.Log

object ShaderUtil {
    private val vertexShaderSource =
            "uniform mat4 uMVPMatrix;                           \n" +
            "attribute vec4 aPosition;                          \n" +
            "attribute vec4 aColor;                             \n" +
            "attribute vec2 aTexCoord;                          \n" +
            "varying vec4 vColor;                               \n" +
            "varying vec2 vTexCoord;                            \n" +
            "void main() {                                      \n" +
            "  vColor = aColor;                                 \n" +
            "  vTexCoord = aTexCoord;                           \n" +
            "  gl_Position = aPosition;                         \n" +
            "}                                                  \n"

    private val fragmentShaderSource =
            "#extension GL_OES_EGL_image_external : require     \n" +
            "precision mediump float;                           \n" +
            "uniform samplerExternalOES uTexture;               \n" +
            "varying vec4 vColor;                               \n" +
            "varying vec2 vTexCoord;                            \n" +
            "void main() {                                      \n" +
            "  gl_FragColor = texture2D(uTexture, vTexCoord);   \n" +
            "}                                                  \n"

    fun createShader(): Int {
        val vertexShader =
                createShaderFromSource(GLES20.GL_VERTEX_SHADER, ShaderUtil.vertexShaderSource)
        val fragmentShader =
                createShaderFromSource(GLES20.GL_FRAGMENT_SHADER, ShaderUtil.fragmentShaderSource)
        return createShaderProgram(vertexShader, fragmentShader)
    }

    private fun createShaderFromSource(type: Int, source: String): Int {
        val shaderHandle = GLES20.glCreateShader(type)
        if (shaderHandle == 0) {
            Log.e("CustomGlRenderer", "Error creating shader")
            return 0
        }

        GLES20.glShaderSource(shaderHandle, source)
        GLES20.glCompileShader(shaderHandle)
        val status = IntArray(1)
        GLES20.glGetShaderiv(shaderHandle, GLES20.GL_COMPILE_STATUS, status, 0)
        if (status[0] == 0) {
            val error = GLES20.glGetShaderInfoLog(shaderHandle)
            Log.e("CustomGlRenderer", "Error compiling shader: $error")
            GLES20.glDeleteShader(shaderHandle)
            return 0
        }

        return shaderHandle
    }

    private fun createShaderProgram(vertexShader: Int, fragmentShader: Int): Int {
        val shaderHandle = GLES20.glCreateProgram()

        if (shaderHandle == 0) {
            Log.e("CustomGlRenderer", "Error creating shader program")
            return 0
        }

        GLES20.glAttachShader(shaderHandle, vertexShader)
        GLES20.glAttachShader(shaderHandle, fragmentShader)
        GLES20.glBindAttribLocation(shaderHandle, 0, "aPosition")
        GLES20.glBindAttribLocation(shaderHandle, 1, "aColor")
        GLES20.glLinkProgram(shaderHandle)

        val status = IntArray(1)
        GLES20.glGetProgramiv(shaderHandle, GLES20.GL_LINK_STATUS, status, 0)

        if (status[0] == 0) {
            GLES20.glDeleteProgram(shaderHandle)
            return 0
        }

        return shaderHandle
    }
}