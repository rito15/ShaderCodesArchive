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
 * DEFINITIONS
 **************************************************************************************************/
#define S(a, b, t) smoothstep(a, b, t)


/**************************************************************************************************
 * DEBUG Functions 
 **************************************************************************************************/
float3 debugCenterLine(float2 uv)
{
    if(uv.x > 0.498 && uv.x < 0.502 || uv.y > 0.498 && uv.y < 0.502)
        return float3(1., 0., 0.);
}
float3 debugOutLine(float2 uv)
{
    if(uv.x > 1.0 && uv.x <= 1.004 || uv.x < 0.0 && uv.x >= -0.004)
        return float3(0., 0., 1.);
}
float3 debugGrid(float2 uv, float interval)
{
    // interval마다 그리드 디버그
    float grid = 0.;
    float gridZ = 0.;
    float2 gridXY = float2(0.);
    
    float th = 0.002; // thickness
    
    for(float f = interval; f < 1.0; f += interval)
    {
        // 가로선 || 세로선
        if(uv.y >= f - th && uv.y <= f + th && uv.x > 0. && uv.x < 1. ||
           uv.x >= f - th && uv.x <= f + th)
        {
            grid = 0.7;
            gridXY = uv + float2(0.2, 0.4);
            
            if( frac(f * 4.) < 0.01 )
            {
                grid = 1.;
                gridZ = 1.;
            }
        }
    }
    
    return float3(0., grid, gridZ);
    //return float3(gridXY, gridZ); //알록달록
}

/**************************************************************************************************
 * Noise, Random
 **************************************************************************************************/
#define NOISE(uv) frac(sin(uv.x * 1234. + uv.y * 2345.) * 3456.)

float N21(float2 p)
{
    p = frac(p * float2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return frac(p.x * p.y);
}

float Random21(float2 seed, float min, float max)
{
    float t = frac(sin(dot(seed, float2(73.867, 25.241))) * 39482.17593);
    return lerp(min, max, t);
}

float Random11(float seed, float min, float max)
{
    float t = frac(sin(seed * 13.421 + 23.512) * 17593.39482);
    return lerp(min, max, t);
}

/**************************************************************************************************
 * CheckerBoard
 **************************************************************************************************/
// 체크무늬 격자
// uv에 맞물리는 결과를 얻으려면 resolution에 PI의 배수를 넣어줘야 함
float CheckerBoard(float2 uv, float resolution)
{
    return ceil(sin(uv.x * resolution) * sin(uv.y * resolution));
}

// 대각선 체크무늬 격자
float DiagonalCheckerBoard(float2 uv, float resolution)
{
    return clamp(ceil(sin(uv.x * resolution) + sin(uv.y * resolution)), 0., 1.);
}


/**************************************************************************************************
 * Main
 **************************************************************************************************/
void mainImage( out float4 fragColor, in float2 fragCoord )
{
    // Shadertoy To Unity
    float4 _Time;
    _Time.y = iTime;
    
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
    
    
    
    
    
    
    // 디버그 옵션
    col += debugCenterLine(uv); // 중심   디버그
    col += debugOutLine(uv);    // 테두리 디버그
    //col += debugGrid(uv, 0.1);  // 그리드 디버그 : uv
    //col += debugGrid(uv, 0.05); // 그리드 디버그 : uv2
    
    fragColor = float4(col,1.0);
}
