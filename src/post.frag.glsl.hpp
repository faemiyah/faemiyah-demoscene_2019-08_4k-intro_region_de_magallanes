#ifndef __g_shader_fragment_post_header__
#define __g_shader_fragment_post_header__
static const char *g_shader_fragment_post = ""
#if defined(USE_LD)
"post.frag.glsl"
#else
"float a(float t,float e)"
"{"
"float o=abs(t-e);"
"return o/t*2;"
"}"
"void main()"
"{"
"p();"
"vec2 e=vec2(0,.003);"
"vec4 t=texture(r,l);"
"o=t-a(t.q,texture(r,l+e.st).q)-a(t.q,texture(r,l+e.ts).q)-a(t.q,texture(r,l-e.st).q)-a(t.q,texture(r,l-e.ts).q);"
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
