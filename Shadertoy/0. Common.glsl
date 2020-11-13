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

#define PI 3.141592653589793


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
