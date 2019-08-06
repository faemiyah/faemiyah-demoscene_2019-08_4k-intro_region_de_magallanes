//#g_shader_header
#version 430

layout(location=0) uniform sampler2D noise2;
layout(location=1) uniform sampler3D noise3;
layout(location=2) uniform sampler2D fbo;
layout(location=3) uniform int ticks;

#if defined(USE_LD)
layout(location=5) uniform vec3 uniform_array[4];
layout(location=9) uniform mat3 rot;
#else
//const mat3 rot = mat3(-0.83, 0.52, 0.21, -0.55, -0.68, -0.47, -0.10, -0.51, 0.85);
const mat3 rot = mat3(0.94, -0.27, 0.20, -0.18, -0.90, -0.41, 0.29, 0.35, -0.89);
#endif

out vec4 output_color;

vec3 dir;
vec2 texcoord;

vec3 calculate_direction()
{
    // Direction array. Arranged into groups of 10.
    // 0: End timestamp.
    // 1-3 Start position.
    // 4-6 End position.
    // 7-9 Forward direction.
    float g_direction[70] = float[]
        (
         // First segment, looking at the sea.
         820,
         -22, 8, 12,
         -20, 8, 8,
         0.5, -0.1, -0.9,

         // Reveal of specular.
         820,
         12, 5.5, -16,
         12, 5.7, -20,
         1, 0, -0.1,

         // Looking at sun.
         1030,
         56, 40, -62,
         57, 43, -72,
         1, 0, 0.1,

         // Portal opening.
         1920,
         15, 9, -19,
         17, 8, -18,
         0.17, 0.17, -0.97,

         // Portal encompassing.
         1630,
         -71, 7, 20,
         -70, 7, 25,
         0.2, 0.4, -1,

         // Worm side look.
         820,
         -90, 15, -40,
         -80, 15, 0,
         0.9, 0.4, 0.1,

         // Final (worm front look).
         1000,
         -1, 26, 79,
         -1, 34, 89,
         -0.3, 0.5, -0.8
             );

    float cticks = ticks;
    for(int ii = 0;; ii += 10)
    {
        if(g_direction[ii] > cticks)
        {
            vec3 fw = normalize(vec3(g_direction[ii + 7], g_direction[ii + 8], g_direction[ii + 9]));
            vec3 up = vec3(0, 1, 0);
            vec3 rt = normalize(cross(fw, up));
            float mixer = cticks / g_direction[ii];
            
#if defined(USE_LD)
            // Direction mode.
            if(uniform_array[3].x != 0)
            {
                fw = uniform_array[1];
                up = uniform_array[2];
                rt = normalize(cross(fw, up));
            }
#endif

            // Write out direction.
            vec2 vertex = gl_FragCoord.xy/vec2(1280, 720)*2-1;
            dir = normalize(fw + (rt * vertex.x * 1.78 + up * vertex.y));
            texcoord = vertex * 0.5 + 0.5;

#if defined(USE_LD)
            // Direction mode.
            if(uniform_array[3].x != 0)
            {
                return uniform_array[0];
            }
#endif
            // Exit by returning position.
            return mix(vec3(g_direction[ii + 1], g_direction[ii + 2], g_direction[ii + 3]), vec3(g_direction[ii + 4], g_direction[ii + 5], g_direction[ii + 6]), mixer);
        }
        cticks -= g_direction[ii];
    }
}
