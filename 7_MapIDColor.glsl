// 本代码初始化基于 6_raymarching.glsl
// 在 Shadertoy 上查看着色器时，您可能会看到使用标识符或 ID 为场景中的每个唯一对象着色的代码。
// 人们经常使用 map 函数而不是 sdScene 函数。
// 您可能还会看到一个 render 函数，该函数通过查看从光线行进算法返回的最近对象的 ID 来处理为每个对象分配颜色

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;
const vec3 COLOR_BACKGROUND = vec3(0.835, 1, 1);

// 计算射线的点到球心的距离，返回 SignDistance
float sdSphere(vec3 p, float r, vec3 offset)
{
    return length(p - offset) - r;
}

float sdFloor(vec3 p)
{
    float d = p.y + 1.;
    return d;
}

vec2 opU(vec2 d1, vec2 d2)
{
    return (d1.x < d2.x) ? d1 : d2;
}

// map: vec2(sd, id)
// 由于浮点精度，为了保证之后比较id，这里没有采用整数id
// https://shadertoy.peakcoder.com/color-3d-sdf/unique-color#733-%E6%96%B9%E6%B3%95%E4%B8%89
vec2 map(vec3 p)
{
    vec2 res = vec2(1e10, 0.0);                 // ID = 0
    vec2 flooring = vec2(sdFloor(p), 0.5);      // ID = 0.5
    vec2 sphereLeft = vec2(sdSphere(p, 1., vec3(-2.5, 0, -2)), 1.5); // ID = 1.5
    vec2 sphereRight = vec2(sdSphere(p, 1., vec3(2.5, 0, -2)), 2.5); // ID = 2.5

    res = opU(res, flooring);
    res = opU(res, sphereLeft);
    res = opU(res, sphereRight);

    return res;
}

vec2 rayMarch(vec3 ro, vec3 rd)
{
    float depth = MIN_DIST;
    vec2 res = vec2(0.);
    float id = 0.;

    for(int i = 0; i < MAX_MARCHING_STEPS; i++)
    {
        vec3 p = ro + depth * rd;
        res = map(p); // find resulting target hit by ray
        depth += res.x;
        id = res.y;
        if(res.x < PRECISION || depth > MAX_DIST)
        {
            break;
        }
    }
    return vec2(depth, id);
}

vec3 calcNormal_swizzling(vec3 p) {
  vec2 e = vec2(1.0, -1.0) * 0.0005; // epsilon
  float r = 1.; // radius of sphere
  return normalize(
    e.xyy * map(p + e.xyy).x +
    e.yyx * map(p + e.yyx).x +
    e.yxy * map(p + e.yxy).x +
    e.xxx * map(p + e.xxx).x);
}

vec3 render(vec3 ro,vec3 rd)
{
    vec3 col = COLOR_BACKGROUND;
    vec2 res = rayMarch(ro, rd);

    float d = res.x;

    if(d > MAX_DIST)
        return col;

    float id = res.y;   // id of  object

    vec3 p = ro + rd * d;

    vec3 normal = calcNormal_swizzling(p);
    vec3 lightPosition = vec3(2,2,7);
    vec3 lightDirection = normalize(lightPosition - p);

    float dif = clamp(dot(normal, lightDirection), 0.3, 1.0);

    if(id > 0.0)    col = dif * vec3(1.0 + 0.7 * mod(floor(p.x) + float(p.z), 2.0));
    if (id > 1.) col = dif * vec3(0, .8, .8);
    if (id > 2.) col = dif * vec3(1, 0.58, 0.29);

    col + COLOR_BACKGROUND * 0.2;

    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    vec3 backgroundColor = vec3(0.835, 1, 1);

    vec3 col = vec3(0);

    vec3 ro = vec3(0,0,3);
    vec3 rd = normalize(vec3(uv,-1));       // 每个像素不同的光线方向

    col = render(ro, rd);

    // Output to screen
    fragColor = vec4(col,1.0);
}