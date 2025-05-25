// #define和const 之间存在差异
const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;

// 计算射线的点到球心的距离，返回 SignDistance
float sdSphere(vec3 p, float r, vec3 offset)
{
    return length(p - offset) - r;
}

// TODO: 7.2 添加地板
float sdFloor(vec3 p)
{
    return p.y + 1.0;
}

// 返回场景最近的形状
float sdScene(vec3 p)
{
    // TODO: 7.1 添加多个物体
    float sphere_left = sdSphere(p, 1.0, vec3(-1.5, 0, -2));
    float sphere_right = sdSphere(p, 1.0, vec3( 1.5 ,0, -2));
    float res = min(sphere_left, sphere_right);

    res = min(sdFloor(p),res);
    return res;
}

float rayMarch(vec3 ro, vec3 rd, float start, float end)
{
    float depth = start;

    for(int i = 0; i < MAX_MARCHING_STEPS; i++)
    {
        vec3 p = ro + depth * rd;
        float d = sdScene(p);
        depth += d;
        if(d < PRECISION || depth > end)
        {
            break;
        }
    }
    return depth;
}

vec3 calcNormal_swizzling(vec3 p) {
  vec2 e = vec2(1.0, -1.0) * 0.0005; // epsilon
  float r = 1.; // radius of sphere
  return normalize(
    e.xyy * sdScene(p + e.xyy) +
    e.yyx * sdScene(p + e.yyx) +
    e.yxy * sdScene(p + e.yxy) +
    e.xxx * sdScene(p + e.xxx));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    vec3 backgroundColor = vec3(0.835, 1, 1);

    vec3 col = vec3(0);

    vec3 ro = vec3(0,0,3);
    vec3 rd = normalize(vec3(uv,-1));       // 每个像素不同的光线方向

    float depth = rayMarch(ro, rd, MIN_DIST, MAX_DIST);

    if(depth > MAX_DIST)
    {
        col = backgroundColor;
    }
    else
    {
        vec3 p = ro + rd * depth;
        vec3 normal = calcNormal_swizzling(p);

        vec3 lightPosition = vec3(2,2,7);
        vec3 lightDirection = normalize(lightPosition - p);

        float dif = clamp(dot(normal, lightDirection),0.3,1.0);

        col = dif * vec3(1, 0.58, 0.29) + backgroundColor * .2;
    }

    // Output to screen
    fragColor = vec4(col,1.0);
}