//#g_shader_fragment_quad

const vec3 LIGHT_DIRECTION = normalize(vec3(1, 0.7, -0.3));
const vec3 I_TERRAIN_COLOR = vec3(0.36, 0.33, 0.3);
const vec3 I_WATER_COLOR = vec3(0.33, 0.43, 0.48);
const vec3 I_MOSA_COLOR = vec3(0.9, 0.4, 0.44);
const vec3 I_SUN_COLOR = vec3(1.3, 1.1, 0.9);
const float END_OF_THE_WORLD = smoothstep(7600, 8800, ticks);
const float I_PI = 3.14159;

float cutoff_normalize(float op, float lvl)
{
    if(op > lvl)
    {
        return (op - lvl) / (1 - lvl);
    }
    return (-lvl + op) / lvl;
}

float sample_noise2(vec2 pos)
{
    float ret = cutoff_normalize(texture(noise2, pos).r, 0.33);
    float inv = 1 - abs(ret);
    return sign(ret) * (1 - inv * inv * inv);
}

float sample_noise3(vec3 pos)
{
    return normalize(texture(noise3, pos).rgb).r;
}

float brownian2(vec3 pos)
{
#if 0
    mat2 rot2 = mat2(rot);
    vec2 pos2 = pos.xz + pos.y * vec2(0, 0.3);
    float ret = 0;
    float mul = 1;
    float downgrade_pos = 5.1;
    float downgrade_mul = -0.11;
    for(int ii = 0; ii < 2; ++ii)
    {
        pos2 = rot2 * pos2;
        ret += sample_noise2(pos2) * mul;
        mul *= downgrade_mul;
        pos2 *= downgrade_pos;
    }
    return ret * max((1 - abs(pos.z) * 49), 0);
#else
    mat2 rot2 = mat2(rot);
    vec2 pos2 = rot2 * (pos.xz + pos.y * vec2(0, 0.3));
    return (sample_noise2(pos2) + sample_noise2(rot2 * (pos2 * 5.1)) * -0.11) * max((1 - abs(pos.z) * 49), 0);
#endif
}

float brownian3(vec3 pos)
{
#if 0
    float ret = 0;
    float mul = 1;
    float downgrade_pos = 2.2;
    float downgrade_mul = -0.2;
    for(int ii = 0; ii < 2; ++ii)
    {
        pos = rot * pos;
        ret += sample_noise3(pos) * mul;
        mul *= downgrade_mul;
        pos *= downgrade_pos;
    }
    return ret * max((1 - abs(pos.z) * 0.05), 0);
#else
    vec3 pos3 = rot * pos;
    return (sample_noise3(pos3) + sample_noise3(rot * (pos3 * 2.2)) * -0.2) * max((1 - abs(pos.z) * 0.05), 0);
#endif
}

float fog(vec3 pos)
{
    float ret = 0;
    float mul = 1;
    float pmul = 0.9;
    float rmul = 0.9;

    for(int ii = 0; ii < 11; ++ii)
    {
        pos = rot * pos * pmul;
        ret += sample_noise3(pos) * mul;
        mul *= rmul;
    }

    return ret;
}

float sdf_julia(vec2 fn, vec2 jconstant)
{
    vec2 dd = vec2(1, 0);
    for(int ii = 0; ii < 11; ++ii)
    {
        float ee = length(fn);
        if(ee > 4)
        {
            return 0.5 * log(ee) * ee / length(dd);
        }

        dd = vec2(fn.x * dd.x - fn.y * dd.y, fn.x * dd.y + fn.y * dd.x) * 2;
        fn = vec2(fn.x * fn.x - fn.y * fn.y, fn.x * fn.y * 2) + jconstant;		
    }
    return -0.1;
}

float sdf(int idx, vec3 pos)
{
    // Water.
    if(idx == 0)
    {
        float val = pos.y;
        if(abs(val) < 1)
        {
            vec3 movement = vec3(0, ticks * 0.0001, 0);
            val += normalize(texture(noise3, pos.xzz * 0.0044 - movement).rgb - texture(noise3, pos * 0.0033 + movement).rgb).r * 0.05;
        }
        return val;
    }
    // Shore.
    if(idx == 1)
    {
        float val = pos.y * 0.11 - pos.z * 0.01 - 0.5;
        if(abs(pos.y) < 22)
        {
            val += brownian2(pos * 0.00022) * (0.8 + END_OF_THE_WORLD * 5) + brownian3(pos * 0.015 - END_OF_THE_WORLD * vec3(0.0, 2.2, 0.0)) * 0.033 * mix(1.0, pos.y, END_OF_THE_WORLD);
        }
        if(pos.z > 0)
        {
            val -= sqrt(pos.z) * 0.01;
        }
        return val - END_OF_THE_WORLD * 0.5;
    }
    // Mösä.
    vec2 mouth = vec2(-180, -145) + smoothstep(4400, 4600, ticks) * 100 + (max(ticks - 4600, 0) * 0.06) - max(ticks - 6300, 0) * 0.05;
    //vec2 i_deadZone = vec2(-0.56, -0.5); //open
    vec2 i_deadZone = vec2(0.55, 1) + smoothstep(7450, 7900, ticks) * vec2(-0.56-0.55, -0.5-1);
    float keepHeadStill = smoothstep(7450, 7900, ticks)*0.25;
    float scale = smoothstep(4400, 4500, ticks) * 10;
    vec2 wormCenterPos = vec2(50, 40);

    if(ticks > 4589)
    {
        wormCenterPos = vec2(-30, 50);
    }

    //float mouthBeginStepFunc = 0.5 - 0.5*tanh(0.15*(pos.z - mouth.x));
    //float i_trailEaseStepFunc = 0.5 - 0.5*tanh(0.05*(pos.z + mouth.y));

    float mouthBeginStepFunc = smoothstep(mouth.x+30, mouth.x-20, pos.z);
    float i_trailEaseStepFunc = smoothstep(mouth.y-20, mouth.y-250, pos.z);

    float insideMouthLerp = clamp((pos.z-mouth.x) / abs(mouth.y - mouth.x), 0, 1);

    vec2 orbiterTrailDisplacement = vec2(25*cos(0.037*(pos.z + ticks*0.3)) + 9*cos(0.043*(pos.z + ticks*0.3)), 14*cos(0.041*(pos.z + ticks*0.3)) + 7*cos(0.051*(pos.z + ticks*0.3)));

    vec2 i_orbiterTrailDisplacementMixed = mix((0.25-keepHeadStill)*orbiterTrailDisplacement, orbiterTrailDisplacement, i_trailEaseStepFunc);
	
    vec2 i_orbiterTrail = vec2(0.45*cos(0.089*pos.z), 0.45*sin(0.091*pos.z));
    vec2 i_orbiterMouthEnd = vec2(0.25, 0);
    vec2 orbiterMouthBegin = vec2(0.44, 0);

    // Create a deadzone inside the mouth so that I can make its end close
    vec2 mouthTransfer = pos.xy - wormCenterPos + i_orbiterTrailDisplacementMixed;
    vec2 i_transfer = normalize(mouthTransfer)*i_deadZone*(1-cos(insideMouthLerp*(I_PI / 2)))*scale;
    mouthTransfer = mouthTransfer + i_transfer;

    vec2 i_orbiterMouthShape = mix(i_orbiterMouthEnd, orbiterMouthBegin, insideMouthLerp);
    vec2 i_obiterTrailJunction = mix(orbiterMouthBegin, i_orbiterTrail, mouthBeginStepFunc);
    vec2 i_orbiterFull = mix(i_orbiterMouthShape, i_obiterTrailJunction, mouthBeginStepFunc);

    return sdf_julia(mouthTransfer / scale, i_orbiterFull) * mix(scale, 0.5, insideMouthLerp) - min(mouth.y - pos.z, 0);
}

vec3 grad(int idx, vec3 pos)
{
    vec3 offset = vec3(1, 0, 0);
    return normalize(vec3(sdf(idx, pos + offset.xyy), sdf(idx, pos + offset.yxy), sdf(idx, pos + offset.yyx)));
}

vec3 bisect(int idx, vec3 pos, vec3 new_pos)
{
    for(int jj = 0; jj < 11; ++jj)
    {
        vec3 mid = (new_pos + pos) * 0.5;
        float mid_dist = sdf(idx, mid);

        if(mid_dist < 0)
        {
            new_pos = mid;
        }
        else
        {
            pos = mid;
        }
    }
    return pos;
}

float sdf_step(int idx, vec3 prev_pos, vec3 pos, out vec3 hit, out vec3 nor, out float dist)
{
    float ret = sdf(idx, pos);

    if(ret < 0)
    {
        hit = bisect(idx, prev_pos, pos);
        nor = grad(idx, hit);
        dist = length(hit - prev_pos);
    }

    return ret;
}

float shadow_ray(vec3 pos)
{
    float dist = sdf(1, pos) + 0.4;
    float travelled = 0;
    float shadow = 1;
    float ii = 0;
    while((ii < 1) && (shadow > 0))
    {
        float travel = abs(dist) + travelled * 0.01 + 0.2;
        travelled += travel;
        vec3 new_pos = pos + travel * LIGHT_DIRECTION;

        // Something concrete hit.
        float dist_terrain = sdf(1, new_pos);
        if(dist_terrain < 0)
        {
            return 0;
        }
        if(dist_terrain < 0.04)
        {
            shadow = min(dist_terrain / 0.04, shadow);
        }

        float new_dist = dist_terrain;

        pos = new_pos;
        dist = new_dist;
        ii += 0.022;
    }
    return max(shadow, 0);
}

float light_luma(vec3 nor, vec3 pos, float spec)
{
    nor = normalize(nor + texture(noise3, pos * 0.1).rgb * 0.03 + texture(noise3, pos * 0.2).rgb * 0.05);
    float i_luma = dot(LIGHT_DIRECTION, nor);
    return 0.8 + i_luma * 0.2 + pow(max(dot(LIGHT_DIRECTION, reflect(dir, nor)), 0), 16) * spec;
}

vec2 ilog(vec2 complex_num)
{
  return vec2(log(length(complex_num)), atan(complex_num.y, complex_num.x));
}

vec3 ducks(vec2 input, vec2 params)
{
    vec2 complex_z = input + vec2(0.1, -1.05);
    vec2 cumulative = vec2(0);

    for(int ii = 0; ii < 55; ++ii)
    {
        vec2 i_iabs = vec2(complex_z.x, abs(complex_z.y));
        complex_z = ilog(i_iabs + params);
        cumulative += complex_z;
    }

    return vec3(mix(vec3(-0.2, -0.3, -0.3), vec3(0.9, 0.2, 0.1), pow(cumulative.y * 0.01, 1)) + length(cumulative.x) * 0.06);
}

void main()
{
    vec3 pos = calculate_direction();
    vec3 start_pos = pos;
    vec3 water_nor;
    const float WATER_CUTOFF = 4;
    float water_luma;
    float dist = min(sdf(0, pos), sdf(1, pos));
    float dist_in_water = 0;
    float shadow = 1;
    float travelled = 0;
    float ii = 0;

    // Sky color is default color, can be replaced.
    output_color = vec4(I_SUN_COLOR, max(dot(LIGHT_DIRECTION, dir), 0));

    while(ii < 1)
    {
        float travel = abs(dist) * 1.05 + travelled * 0.008;
        vec3 new_pos = pos + travel * dir;

        // Terrain distance.
        vec3 solid_hit;
        vec3 solid_nor;
        float solid_len;
        float solid_dist = sdf_step(1, pos, new_pos, solid_hit, solid_nor, solid_len);

        // Water accumulates.
        float water_dist = sdf(0, new_pos);
        if(water_dist < 0)
        {
            if(dist_in_water == 0)
            {
                vec3 test_pos = bisect(0, pos, new_pos);
                water_nor = grad(0, test_pos);
                float water_len = length(test_pos - pos);
                if((solid_dist > 0) || (water_len < solid_len))
                {
                    water_luma = light_luma(water_nor, test_pos, 2);
                    dist_in_water += length(new_pos - test_pos);
                    shadow = shadow_ray(test_pos);
                }
            }
            else
            {
                dist_in_water += travel;
            }
            if(dist_in_water >= WATER_CUTOFF)
            {
                travelled += travel - (dist_in_water - WATER_CUTOFF);
                dist_in_water = WATER_CUTOFF;
                break;
            }
        }

        // Hard hits cancel immediately.
        if(solid_dist < 0)
        {
            output_color = vec4(I_TERRAIN_COLOR, light_luma(solid_nor, solid_hit, 0.1));
            if(dist_in_water == 0)
            {
                shadow = shadow_ray(solid_hit);
            }
            travelled += solid_len;
            break;
        }

        float new_dist = min(abs(water_dist), abs(solid_dist));

        // Test against Mösä.
        solid_dist = sdf_step(2, pos, new_pos, solid_hit, solid_nor, solid_len);
        if(solid_dist < 0)
        {
            output_color = vec4(I_MOSA_COLOR, light_luma(solid_nor, solid_hit, 0.5));
            travelled += solid_len;
            break;
        }

        pos = new_pos;
        dist = min(new_dist, abs(solid_dist));
        travelled += travel;
        if(travelled > 444)
        {
            break;
        }
        ii += 0.006;
    }

    if(dist_in_water > 0.0)
    {
        vec4 water_color = vec4(I_WATER_COLOR, water_luma);
        output_color = mix(output_color - dist_in_water * 0.05, water_color, dist_in_water / WATER_CUTOFF);
    }
    output_color.a *= 0.4 + shadow * 0.6;

    // Mix linear travel with smoothstep travel to erase the sharp line.
    travelled *= 0.005;
    travelled = mix(travelled, smoothstep(0.0, 1.0, travelled), min(travelled, 1.0));
    
    // Mix with portal.
    float portal_step = smoothstep(770, 6220, ticks) - smoothstep(6200, 6400, ticks);
    float portal_fadein = 1 - portal_step;
    if((portal_fadein > 0) && (portal_step > 0))
    {
        output_color.a *= smoothstep(-0.7, -0.3, -portal_step);

        float portal_diff = dot(normalize(dir * vec3(1, 0.3, 1)), normalize(vec3(0.2, 0.2, -1)));
        float portal = smoothstep(0.3 + portal_fadein, 0.7 + portal_fadein, portal_diff);
        if(portal > 0)
        {
            vec3 col = ducks(dir.xy * 0.05 * pow(portal_diff * 2, sqrt(sqrt(portal_fadein)) * 5 + 2), vec2(0.67, -0.2));
            output_color = mix(output_color, vec4(col, 1), portal);
            travelled = mix(travelled, 1.0001 - travelled, portal);
        }
    }

    vec3 i_end_pos = start_pos + dir * travelled * 100;
    float i_luma = output_color.a;

    vec3 i_fogged = vec3(0.6) + fog(dir * 0.1 + start_pos * 0.01 + i_end_pos * 0.0001) * 0.01;
    output_color = vec4(mix(output_color.rgb * i_luma, i_fogged, mix(travelled, 0, pow(max(dot(LIGHT_DIRECTION, dir), 0), 7))) - cos(ticks * 0.3) * (smoothstep(2400, 2450, ticks) * smoothstep(-2500, -2450, -ticks)) * 0.1 + END_OF_THE_WORLD * mix(vec3(6), vec3(1, 0, 0), travelled), travelled);

    //output_color = vec4(mix(output_color.rgb * i_luma, i_fogged, travelled), travelled);
    //output_color = vec4(vec3(travelled), travelled);
}
