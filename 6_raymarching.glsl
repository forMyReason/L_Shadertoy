// #define和const 之间存在差异
const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;

// 计算点到球心的距离，返回sdf
float sdSphere(vec3 p, float r)
{
    vec3 offset = vec3(0,0,1);
    return length(p - offset) - r;
}

float rayMarch(vec3 ro, vec3 rd, float start, float end)
{
    float depth = start;

    for(int i = 0; i < 255; i++)        // TODO:为什么255
    {
        vec3 p = ro + depth * rd;
        float d = sdSphere(p, 1.0);
        depth += d;
        if(d < 0.001 || depth > end)
        {
            break;
        }
    }
    return depth;
}

vec3 calNormal(vec3 p)
{
    float e = 0.0005;
    float r = 1.0;
    return normalize(vec3(
        sdSphere(vec3(p.x+e, p.y, p.z), r) - sdSphere(vec3(p.x-e, p.y, p.z), r),
        sdSphere(vec3(p.x, p.y+e, p.z), r) - sdSphere(vec3(p.x, p.y-e, p.z), r),
        sdSphere(vec3(p.x, p.y, p.z+e), r) - sdSphere(vec3(p.x, p.y, p.z-e), r)
    )
    );
}

vec3 calcNormal_swizzling(vec3 p) {
  vec2 e = vec2(1.0, -1.0) * 0.0005; // epsilon
  float r = 1.; // radius of sphere
  return normalize(
    e.xyy * sdSphere(p + e.xyy, r) +
    e.yyx * sdSphere(p + e.yyx, r) +
    e.yxy * sdSphere(p + e.yxy, r) +
    e.xxx * sdSphere(p + e.xxx, r));
}

vec2 rotate(vec2 uv, float th)
{
    // 按列写值
    return mat2(cos(th),sin(th),-sin(th),cos(th)) * uv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;

    vec3 col = vec3(0);
    

    vec3 ro = vec3(0,0,6);
    vec3 rd = normalize(vec3(uv,-1));       // TODO:每个像素不同的光线方向

    float d = rayMarch(ro, rd, 0.0, 100.0);

    if(d > 100.0)
    {
        col = vec3(0.6);
    }
    else
    {
        vec3 p = ro + rd * d;
        vec3 normal = calcNormal_swizzling(p);
        vec3 lightPosition = vec3(vec2(rotate(vec2(2,2), 1.25 * iTime)),5);
        vec3 lightDirection = normalize(lightPosition - p);
        float dif = clamp(dot(normal, lightDirection),0.0,1.0);
        col = vec3(dif) * vec3(1,0.58,0.29);
    }

    // Output to screen
    fragColor = vec4(col,1.0);
}