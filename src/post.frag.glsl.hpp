static const char *g_shader_fragment_post = ""
#if defined(USE_LD)
"post.frag.glsl"
#else
"float c(float t,float e)"
"{"
"float o=abs(t-e);"
"return o/t*2;"
"}"
"void main()"
"{"
"x();"
"vec2 e=vec2(0,.003);"
"vec4 t=texture(r,s);"
"o=t-c(t.q,texture(r,s+e.st).q)-c(t.q,texture(r,s+e.ts).q)-c(t.q,texture(r,s-e.st).q)-c(t.q,texture(r,s-e.ts).q);"
"}"
#endif
"";
