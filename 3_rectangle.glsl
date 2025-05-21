vec2 rotate(vec2 uv, float th)
{
    // 按列写值
    return mat2(cos(th),sin(th),-sin(th),cos(th)) * uv;
}

vec3 DrawRectangle(vec2 uv, float size, vec2 offset)
{
    float x = uv.x - offset.x;
    float y = uv.y - offset.y;

    vec2 rotated = rotate(vec2(x,y), iTime);

    float outter = max(abs(rotated.x),abs(rotated.y)) - size;
    return outter > 0.0 ? vec3(0.5) :vec3(1);
}

// TODO: 如果不管显示屏幕的大小怎么移动，正方形都出现在屏幕中间怎么办？
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord/iResolution.xy;
    uv.x *= (iResolution.x / iResolution.y);
    vec2 offset = vec2(0.5);
    vec3 col = DrawRectangle(uv, 0.2, offset);
    fragColor = vec4(col,1.0);
}