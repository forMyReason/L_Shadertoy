// 平滑交集：smooth min
// Same as Polynomial Smooth Minimum by Inigo Quilez
float smin(float a, float b, float k) {
  float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k*h*(1.0-h);
}

// 平滑并集：smooth max
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

// key
vec3 drawScene(vec2 uv) {
    vec3 col = getBackgroundColor(uv);
    float d1 = sdCircle(uv, 0.1, vec2(0., 0.0 + 0.2 * sin(iTime * 1.0)));
    float d2 = sdSquare(uv, 0.1, vec2(0.1, 0.0 - 0.2 * sin(iTime * 1.0)));

    float res; // result
    res = d2;
    res = step(0., res); // Same as res > 0. ? 1. : 0.;

    // Antialias Entire Result
    res = smin(d1, d2, 0.05);
    res = smoothstep(0., 0.02, res);

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