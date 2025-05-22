vec3 draw_circle(vec2 uv, float radius)
{
    float x = uv.x;
    float y = uv.y;
    float length = length(vec2(x,y)) - radius;
    return length > 0. ? vec3(0.5,0,0) : vec3(1,1,1);
}

vec3 draw_square(vec2 uv, float size)
{
    float x = uv.x;
    float y = uv.y;

    float outter = max(abs(x),abs(y)) - size;
    return outter > 0. ? vec3(.2) : vec3(1);
}

float sdf_circle(vec2 uv, float radius, vec2 offset)
{
    return length(vec2(uv.x - offset.x, uv.y - offset.y)) - radius;
}

// TODO:为什么画方形，渲染出来总在抖？
float sdf_square(vec2 uv, float size, vec2 offset)
{
    return max(abs(uv.x - offset.x), abs(uv.y - offset.y)) - size;
}

vec2 rotate(vec2 uv, float th)
{
    return uv * mat2(cos(th),sin(th),-sin(th),cos(th));
}

vec3 draw_background(vec2 uv)
{
    // 因为传入的uv是(-0.5,0.5)，所以加(0.5,0.5)
    return vec3(mix(vec2(0.),vec2(1.),uv + vec2(0.5,0.5)),1.0);
}

vec3 draw_scene(vec2 uv)
{
    vec3 col = draw_background(uv);
    float circle = sdf_circle(uv, 0.1, vec2(0.0, 0.0));
    float square = sdf_square(uv, 0.1, vec2(-0.1, 0.1));

    col = mix(vec3(1.,0.,0.), col, step(0.0,square));
    col = mix(vec3(0.,1.,0.6), col, step(0.0,circle));
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    // 让SDF总出现在视野中间
    uv += vec2(-.5,-.5);
    
    uv.x *= (iResolution.x / iResolution.y);

    // 旋转
    // uv = rotate(uv, 2.*iTime);
    
    vec3 col = draw_scene(uv);
    fragColor = vec4(col,1.0);
}