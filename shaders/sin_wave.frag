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

#define PI 3.14159265

float plot(float y, float pct) {
    return smoothstep(y - 0.007, y, pct)
         - smoothstep(y, y + 0.007, pct);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 st = fragCoord.xy / iResolution.xy;

    float y = sin(st.x * 2. * PI + u_time) * 0.5 + 0.5;

    vec3 grad = vec3(y, 0., y);
    float pct = plot(y, st.y);
    vec3 col = (1. - pct) * grad + pct * vec3(1., 1., 1.);
    fragColor = vec4(col, 1.);
}

#ifdef GLSLVIEWER
void main() {
 mainImage(gl_FragColor, gl_FragCoord.xy);
}
#endif