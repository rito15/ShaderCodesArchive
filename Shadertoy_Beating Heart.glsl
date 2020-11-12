/**************************************************************************************************
 * DEFINITIONS : Unity Compatibility
 **************************************************************************************************/
#define float2   vec2
#define float3   vec3
#define float4   vec4
#define float2x2 mat2
#define float3x3 mat3
#define float4x4 mat3

#define frac(x)     fract(x)
#define saturate(x) clamp(x, 0., 1.)

#define atan2(x,y)    atan(y,x)
#define tex2D(s,t)    texture(s,t)
#define mul(mat,vec)  vec*mat;

#define lerp(a,b,t) mix(a,b,t)

/**************************************************************************************************
 * Shapes 
 **************************************************************************************************/
// 하트
float Heart(float2 uv, float2 center, float2 size, float smoothness)
{
    float2  uvHeart   = (uv - center) / size * float2(1.15, 0.97);
    float2  heartBase = float2(uvHeart.x, uvHeart.y - sqrt(abs(uvHeart.x)) * 0.7 + 0.18);
    float heart = smoothstep(0.87, 0.87 - smoothness, length(heartBase));
    return heart;
}

/**************************************************************************************************
 * Functions 
 **************************************************************************************************/
// Smooth Max
float smax(float a, float b, float k)
{
    float h = clamp((b - a) / k + 0.5, 0.0, 1.0);
    return mix(a, b, h) + h * (1.0 - h) * k * 0.5;
}

// 회전 : 기본 시계방향
float2 Rotate(float2 org, float deg)
{
    float2x2 rotMat = float2x2(cos(deg), -sin(deg),
                               sin(deg),  cos(deg));
    return mul(rotMat, org);
}

/**************************************************************************************************
 * UV Functions 
 **************************************************************************************************/
// 타일링
float2 UvTile(float2 uv, float2 size, float2 offset)
{
    return frac(uv * size) - offset;
}

// 회전
float2 UvRotate(float2 uv, float rot)
{
    return Rotate(uv, rot);
}

// 스케일 박동
float2 UvPulse(float2 uv, float range, float t)
{
    return uv * (1. + sin(t)* range);
}

// 꿀렁꿀렁 - a, b, c : 10, 2, 0.2 기본 / t : 시간
float2 UvWave(float2 uv, float a, float b, float c, float t)
{
    float x = abs(uv.x) * a;
    float y = uv.y * b;
    float w = 1. + abs(sin(x * y + t) * sin(x * y + t) * c);
    
    return float2(uv.x * w, uv.y);
}

// 진동
float2 UvVibrate(float2 uv, float a, float b, float c, float t)
{
    float x = abs(uv.x) * a;
    float y = abs(uv.y) * b;
    float w = 1. + abs(sin(t*x * y + t) * sin(t*x * y + t) * c);
    
    return float2(uv.x * w, uv.y * w);
}

// 흩뿌리기
float2 UvScatter(float2 uv, float2 scale)
{
    float x = uv.x;
    float y = uv.y;
    float2 s = 2. - float2(cos(x * scale) * cos(y * scale));
    return uv * s;
}

/**************************************************************************************************
 * Main
 **************************************************************************************************/
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // 해상도를 800x450에서 450x450으로 맞추고 화면 중앙 정렬하기
    float ratioWH = iResolution.x / iResolution.y;
    float ratioHW = iResolution.y / iResolution.x;
    float2 adjMul = float2(ratioWH, 1.);
    float2 adjSub = float2((1.-ratioHW) * 0.5 * ratioWH, 0.);
    float2 uv = (fragCoord/iResolution.xy) * adjMul - adjSub;
    float3 col; // 최종 컬러
    
    // uv2 이동
    float2 uvOffset = float2(0.0, 0.0);
    
    // uv Remap : 0. ~ 1. => -1. ~ 1.
    float2 uv2 = uv *2. - 1. - uvOffset;
    
    // 특정 UV 적용
    //uv2 = UvTile(uv2, float2(2., 2.), float2(0.5));
    //uv2 = UvRotate(uv2, iTime);
    uv2 = UvPulse(uv2, 0.01, iTime * 10.0);
    uv2 = UvWave(uv2, 0.3, 2., 0.2, iTime * 5.0);
    uv2 = UvVibrate(uv2, 15., -10., (sin(iTime * 5.0) * 0.5), iTime * 5.0);
    uv2 = UvScatter(uv2, float2(100.0 * (sin(iTime * 5.0) * 0.5 + 1.)));
    
    // 하트 : uv, center, size, smoothness
    float heart = Heart(uv2, float2(0.,0.), float2(1.6, 0.8), 0.05);
    
    col += heart;
    col *= float3(
        sin(uv.y)*0.5 + 0.5,
        abs(sin(uv2.y + iTime*0.1))*0.1 + sin(abs(iTime * 1.)) * 0.2 + 0.2,
        -abs(sin(uv2.y + iTime*0.1))*0.1 + cos(iTime * 1.) * 0.2 + 0.2);
    
    
    fragColor = vec4(col,1.0);
}
