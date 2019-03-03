#ifdef GLSLVIEWER
// GLSLViewer inputs
uniform sampler2D u_tex;
uniform float u_time;
uniform float u_delta;
uniform vec4 u_date;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
varying vec2 v_texcoord;

// ShaderToy inputs
vec2 iResolution = u_resolution;
float iTime = u_time;
float iTimeDelta = u_delta;
int iFrame = int(iTime / 16.666);
vec4 iMouse = vec4(u_mouse, vec2(0));
vec4 iDate = u_date;
#endif

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Example from ShaderToy

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

    // Output to screen
    fragColor = vec4(col,1.0);
}

#ifdef GLSLVIEWER
void main() {
  mainImage(gl_FragColor, gl_FragCoord.xy);
}
#endif

