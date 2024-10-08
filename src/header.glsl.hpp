#ifndef __g_shader_header_header__
#define __g_shader_header_header__
static const char *g_shader_header = ""
#if defined(USE_LD)
"header.glsl"
#else
"#version 430\n"
"layout(location=0)uniform sampler2D Y;"
"layout(location=1)uniform sampler3D f;"
"layout(location=2)uniform sampler2D r;"
"layout(location=3)uniform int e;"
"mat3 n=mat3(.94,-.27,.2,-.18,-.9,-.41,.29,.35,-.89);"
"out vec4 o;"
"vec3 v;"
"vec2 l;"
"vec3 p()"
"{"
"float o[70]=float[](820,-22,8,12,-20,8,8,.5,-.1,-.9,820,12,5.5,-16,12,5.7,-20,1,0,-.1,1030,56,40,-62,57,43,-72,1,0,.1,1920,15,9,-19,17,8,-18,.17,.17,-.97,1630,-71,7,20,-70,7,25,.2,.4,-1,820,-90,15,-40,-80,15,0,.9,.4,.1,1000,-1,26,79,-1,34,89,-.3,.5,-.8),a=e;"
"for(int t=0;"
";"
"t+=10)"
"{"
"if(o[t]>a)"
"{"
"vec3 c=normalize(vec3(o[t+7],o[t+8],o[t+9])),s=vec3(0,1,0),f=normalize(cross(c,s));"
"float r=a/o[t];"
"vec2 e=gl_FragCoord.st/vec2(1280,720)*2-1;"
"return v=normalize(c+(f*e.s*1.78+s*e.t)),l=e*.5+.5,mix(vec3(o[t+1],o[t+2],o[t+3]),vec3(o[t+4],o[t+5],o[t+6]),r);"
"}"
"a-=o[t];"
"}"
"}"
#endif
"";
#if !defined(DNLOAD_RENAME_UNUSED)
#if defined(__GNUC__)
#define DNLOAD_RENAME_UNUSED __attribute__((unused))
#else
#define DNLOAD_RENAME_UNUSED
#endif
#endif
#endif
