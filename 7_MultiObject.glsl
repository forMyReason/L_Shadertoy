// #define和const 之间存在差异
const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;

struct Surface
{
    float sd;   // sign distance value
    vec3 col;   // color
};

// 计算射线的点到球心的距离，返回 SignDistance
Surface sdSphere(vec3 p, float r, vec3 offset, vec3 col)
{
    float d = length(p - offset) - r;
    return Surface(d, col);
}

// TODO: 7.2 添加地板
Surface sdFloor(vec3 p, vec3 col)
{
    float d = p.y + 1.0;
    return Surface(d, col);
}

Surface minWithColor(Surface obj1, Surface obj2)
{
    if (obj2.sd < obj1.sd)
        return obj2;
    return obj1;
}

// 棋盘格地板
Surface sdScene(vec3 p) {
  Surface sphereLeft = sdSphere(p, 1., vec3(-2.5, 0, -2), vec3(0, .8, .8));
  Surface sphereRight = sdSphere(p, 1., vec3(2.5, 0, -2), vec3(1, 0.58, 0.29));
  Surface co = minWithColor(sphereLeft, sphereRight);

  vec3 floorColor = vec3(1. + 0.7*mod(floor(p.x) + floor(p.z), 2.0));
  Surface sd_floor = sdFloor(p, floorColor);

  co = minWithColor(co, sd_floor);
  return co;
}

// 纯色地板
// Surface sdScene(vec3 p)
// {
//     // TODO: 7.1 添加多个物体
//     Surface sphere_left = sdSphere(p, 1.0, vec3(-1.5, 0, -2), vec3(0, .8, .8));
//     Surface sphere_right = sdSphere(p, 1.0, vec3( 1.5 ,0, -2), vec3(1, 0.58, 0.29));
//     Surface sd_floor = sdFloor(p, vec3(0,1,0));

//     Surface co = minWithColor(sphere_left, sphere_right);
//     co = minWithColor(sd_floor, co);
//     return co;
// }

Surface rayMarch(vec3 ro, vec3 rd, float start, float end)
{
    float depth = start;
    Surface co;

    for(int i = 0; i < MAX_MARCHING_STEPS; i++)
    {
        vec3 p = ro + depth * rd;
        co = sdScene(p);
        depth += co.sd;
        if(co.sd < PRECISION || depth > end)
            break;
    }

    co.sd = depth;
    return co;
}

vec3 calcNormal_swizzling(vec3 p) {
  vec2 e = vec2(1.0, -1.0) * 0.0005; // epsilon
  float r = 1.; // radius of sphere
  return normalize(
    e.xyy * sdScene(p + e.xyy).sd +
    e.yyx * sdScene(p + e.yyx).sd +
    e.yxy * sdScene(p + e.yxy).sd +
    e.xxx * sdScene(p + e.xxx).sd);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    vec3 backgroundColor = vec3(0.835, 1, 1);

    vec3 col = vec3(0);

    vec3 ro = vec3(0,0,3);
    vec3 rd = normalize(vec3(uv,-1));       // 每个像素不同的光线方向

    Surface co = rayMarch(ro, rd, MIN_DIST, MAX_DIST);

    if(co.sd > MAX_DIST)
    {
        col = backgroundColor;
    }
    else
    {
        vec3 p = ro + rd * co.sd;
        vec3 normal = calcNormal_swizzling(p);

        vec3 lightPosition = vec3(2,2,7);
        vec3 lightDirection = normalize(lightPosition - p);

        float dif = clamp(dot(normal, lightDirection),0.3,1.0);

        col = dif * co.col + backgroundColor * .2;
    }

    // Output to screen
    fragColor = vec4(col,1.0);
}