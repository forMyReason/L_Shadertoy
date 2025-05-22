// 心形SDF
// (x^2 + y^2 - 1)^3 - x^2*y^3 = 0
float sdHeart(vec2 uv, float size, vec2 offset) {
    float x = uv.x - offset.x;
    float y = uv.y - offset.y;
    float xx = x * x;
    float yy = y * y;
    float yyy = yy * y;
    float group = xx + yy - size;
    float d = group * group * group - xx * yyy;

    return d;
}

vec3 drawScene(vec2 uv) {
    vec3 col = vec3(1);
    float heart = sdHeart(uv, 0.02, vec2(0));

    col = mix(vec3(1, 0, 0), col, step(0., heart));

    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy; // <0, 1>
    uv -= 0.5; // <-0.5,0.5>
    uv.x *= iResolution.x/iResolution.y; // fix aspect ratio

    vec3 col = drawScene(uv);

    // Output to screen
    fragColor = vec4(col,1);
}