// 平滑并集：smooth min
float smin(float a, float b, float k) {
  float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k*h*(1.0-h);
}

// 平滑交集：smooth max
float smax(float a, float b, float k) {
  return -smin(-a, -b, k);
}

vec3 getBackgroundColor(vec2 uv) {
    uv = uv * 0.5 + 0.5; // remap uv from <-0.5,0.5> to <0.25,0.75>
    vec3 gradientStartColor = vec3(1., 0., 1.);
    vec3 gradientEndColor = vec3(0., 1., 1.);
    return mix(gradientStartColor, gradientEndColor, uv.y); // gradient goes from bottom to top
}

float sdCircle(vec2 uv, float r, vec2 offset) {
    float x = uv.x - offset.x;
    float y = uv.y - offset.y;

    return length(vec2(x, y)) - r;
}

float sdSquare(vec2 uv, float size, vec2 offset) {
    float x = uv.x - offset.x;
    float y = uv.y - offset.y;

    return max(abs(x), abs(y)) - size;
}

float opSymX(vec2 p, float r)
{
    p.x = abs(p.x);
    return sdCircle(p, r, vec2(0.2, 0));
}

float opSymY(vec2 p, float r)
{
    p.y = abs(p.y);
    return sdCircle(p, r, vec2(0, 0.2));
}

float opSymXY(vec2 p, float r)
{
    p = abs(p);
    return sdCircle(p, r, vec2(0.2));
}

float opRep(vec2 p, float r, vec2 c)
{
    vec2 q = mod(p+0.5*c,c)-0.5*c;
    return sdCircle(q, r, vec2(0));
}

float opRepLim(vec2 p, float r, float c, vec2 l)
{
    vec2 q = p-c*clamp(round(p/c),-l,l);
    return sdCircle(q, r, vec2(0));
}

// 您还可以通过操纵 uv 坐标，并将其与从 SDF 返回的值相加，对 SDF 执行变形或扭曲。
// 在 opDisplace 操作中，您可以创建任何类型的数学运算来替换 p 的值
// 然后将该结果添加到您从 SDF 返回的原始值中
float opDisplace(vec2 p, float r)
{
    float d1 = sdCircle(p, r, vec2(0));
    float s = 0.5; // scaling factor

    float d2 = sin(s * p.x * 1.8); // Some arbitrary values I played around with

    return d1 + d2;
}

// key
vec3 drawScene(vec2 uv) {
    vec3 col = getBackgroundColor(uv);
    float d1 = sdCircle(uv, 0.1, vec2(0., 0.));
    float d2 = sdSquare(uv, 0.1, vec2(0.1, 0));

    float res; // result
    res = d2;

    // Union
    res = min(d1, d2);

    // Insert
    res = max(d1, d2);

    // Subtraction
    res = max(-d1, d2);     // d2 - d1
    res = max(d1, -d2);     // d1 - d2

    // XOR
    res = max(min(d1, d2), -max(d1, d2));

    // Smooth Union
    res = smin(d1, d2, 0.05);

    // Smooth Intersection
    res = smax(d1, d2, 0.05);

    // Symmetry align X
    res = opSymX(uv, 0.1);
    res = opSymY(uv, 0.1);
    res = opSymXY(uv, 0.1);

    // Repeat
    res = opRep(uv, 0.05, vec2(0.2, 0.15));

    // Repeat in Specific Aera
    res = opRepLim(uv, 0.05, 0.15, vec2(2, 1));

    // Deformation and Distortion
    res = opDisplace(uv, 0.1); // Kinda looks like an egg
    
    res = step(0., res); // Same as res > 0. ? 1. : 0.;

    col = mix(vec3(1,0,0), col, res);
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy; // <0, 1>
    uv -= 0.5; // <-0.5,0.5>
    uv.x *= iResolution.x/iResolution.y; // fix aspect ratio

    vec3 col = drawScene(uv);

    fragColor = vec4(col,1.0); // Output to screen
}