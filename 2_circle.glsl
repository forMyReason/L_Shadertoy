vec3 sdfCircle(vec2 uv, float r, vec2 offset, float width)
{
    float x = uv.x - offset.x;
    float y = uv.y - offset.y;

    float outter = length(vec2(x,y)) - r;
    return outter > 0.0 ? vec3(0.5) :vec3(cos(iTime + uv.xyx + vec3(0,2,4)) * 0.5 + 0.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord / iResolution.xy - 0.5);
    uv.x *= (iResolution.x / iResolution.y);
    float speed = 0.0f;
    float amplitude = 0.0f;
    float radius = 0.1f;
    vec2 offset = vec2(amplitude * sin(iTime * speed), amplitude * cos(iTime * speed));
    vec3 col = sdfCircle(uv, radius, offset, 0.1);
    fragColor = vec4(col, 1.0);
}