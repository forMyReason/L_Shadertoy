float sdfCircle(vec2 uv, float r, vec2 offset) {
  float x = uv.x - offset.x;
  float y = uv.y - offset.y;

  return length(vec2(x, y)) - r;
}

float sdfSquare(vec2 uv, float size, vec2 offset)
{
    float x = uv.x - offset.x;
    float y = uv.y - offset.y;

    return max(abs(x), abs(y)) - size;
}

vec3 drawScene(vec2 uv) {
  vec3 col = vec3(1);
  float circle = sdfCircle(uv, 0.1, vec2(0, 0));
  float square = sdfSquare(uv, 0.07, vec2(0.1,0));
  col = mix(vec3(0.0, 0.0, 1.0),col,step(0.,circle));
  col = mix(vec3(1.0, 0.0, 0.0),col,step(0.,square));
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = fragCoord/iResolution.xy; // <0, 1>
  uv -= 0.5; // <-0.5,0.5>
  uv.x *= iResolution.x/iResolution.y;

  vec3 col = drawScene(uv);

  fragColor = vec4(col,1.0);
}