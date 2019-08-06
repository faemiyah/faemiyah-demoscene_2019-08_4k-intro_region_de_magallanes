//#g_shader_fragment_post

float dcoeff(float dist, float cmp)
{
    float diff = abs(dist - cmp);
    return diff / dist * 2;
}

void main()
{
    calculate_direction();

    vec2 offset = vec2(0, 0.003);
    vec4 col = texture(fbo, texcoord);
    float i_diff1 = texture(fbo, texcoord + offset.xy).a;
    float i_diff2 = texture(fbo, texcoord + offset.yx).a;
    float i_diff3 = texture(fbo, texcoord - offset.xy).a;
    float i_diff4 = texture(fbo, texcoord - offset.yx).a;
    output_color = col - dcoeff(col.a, i_diff1) - dcoeff(col.a, i_diff2) - dcoeff(col.a, i_diff3) - dcoeff(col.a, i_diff4);
}
