const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const vec3 COLOR_SPHERE = vec3(1.,0.6,0.2);
const vec3 COLOR_BOXFRAME = vec3(1.,0.6,0.2);
const vec3 COLOR_BACKGROUND = vec3(0.835, 1, 1);
const vec3 LIGHT_DIRECTION = vec3(0.2,0.6,0.5);

struct surface
{
    float sd;
    vec3 color;
}s;

surface sdSphere(vec3 p, float radius, vec3 color)
{
    vec3 origin = vec3(0.0);
    float d = length(p - origin) - radius;
    return surface(d,color);
}

surface sdFloor(vec3 p, vec3 col) {
    float d = p.y + 1.;
    return surface(d, col);
}

/// https://iquilezles.org/articles/distfunctions/
/* sdBoxFrame参数
    计算一个带有边框厚度的盒子的表面距离场（SDF），并返回带有颜色信息的 surface 结构体。

    - p：通常表示当前点到物体中心的向量（或坐标），经过了 abs(p)-b 处理，b 一般是盒子的半尺寸（半边长），这样 p 就变成了点到盒子表面的距离向量（带符号）。
    - b：盒子的半尺寸向量（vec3），决定了盒子的大小。
    - e：框的粗细
    - color：物体的颜色，作为参数传递给 surface。
*/
surface sdBoxFrame( vec3 p, vec3 b, float e, vec3 offset, vec3 color)
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return surface(
        min(
            min(length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
            length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0)
        ),
        color);
}

surface minWithColor(surface obj1, surface obj2) {
    if (obj2.sd < obj1.sd)
        return obj2;
    return obj1;
}

surface sdScene(vec3 p, vec3 col) {
    vec3 floorColor = vec3(1. + 0.7*mod(floor(p.x) + floor(p.z), 2.0));
    surface co = sdFloor(p, floorColor);
    co = minWithColor(co, sdBoxFrame(p,  vec3(0.5), 0.035, vec3(5.0), COLOR_BOXFRAME));
    return co;
}

vec3 calcNormal_swizzling(vec3 p) {
  vec2 e = vec2(1.0, -1.0) * 0.0005; // epsilon
  float r = 1.; // radius of sphere
  return normalize(
    e.xyy * sdScene(p + e.xyy, COLOR_SPHERE).sd +
    e.yyx * sdScene(p + e.yyx, COLOR_SPHERE).sd +
    e.yxy * sdScene(p + e.yxy, COLOR_SPHERE).sd +
    e.xxx * sdScene(p + e.xxx, COLOR_SPHERE).sd);
}

surface rayMarch(vec3 ro, vec3 rd, float MIN_DIST, float MAX_DIST)
{
    float depth = MIN_DIST;

    surface s;

    for(int i = 0; i < 255; i++)
    {
        vec3 p = ro + rd * depth;
        s = sdScene(p, COLOR_SPHERE);
        depth += s.sd;

        if(s.sd < 0.001 || depth > MAX_DIST)
            break;
    }

    s.sd = depth;

    return s;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord / iResolution.xy - 0.5);
    uv.x *= (iResolution.x / iResolution.y);

    // 右手系，看向-z
    vec3 ro = vec3(0,0,2);
    vec3 rd = vec3(uv, -1);

    vec3 lightDirection = vec3(0.2,0.6,0.5);
    vec3 col;
    // float depth
    surface co = rayMarch(ro, rd, MIN_DIST, MAX_DIST);
    if(co.sd > MAX_DIST)
        col = COLOR_BACKGROUND;
    else
    {
        vec3 p = ro + rd * co.sd;
        vec3 normal = calcNormal_swizzling(p);
        vec3 lightPosition = vec3(2, 2, 7);
        vec3 lightDirection = normalize(lightPosition - p);

        float dif = clamp(dot(normal, lightDirection), 0.3, 1.); // diffuse reflection

        col = dif * co.color + COLOR_BACKGROUND * .2;
    }
    fragColor = vec4(col, 1.0);
}