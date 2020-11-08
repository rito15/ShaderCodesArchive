/*********************************************************************
* 
**********************************************************************/
// lerp(a, b, t) = a(1 - t) + bt



/*********************************************************************
* 간단한 노이즈 (결과 범위 0~1)
**********************************************************************/

//[1] Define 버전
#define NOISE(uv) frac(sin(uv.x * 1234. + uv.y * 2345.) * 3456.)

//[2] 함수 버전

// N : 노이즈
// 앞의 2 : Input 개수
// 뒤의 1 : Output 개수
float N21(float2 p)
{
    p = frac(p * float2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return frac(p.x * p.y);
}

/*********************************************************************
* Random (결과 범위 지정)
**********************************************************************/

// 1차원
float Random(float seed, float min, float max)
{
    float t = frac(sin(seed * 13.421 + 23.512) * 17593.39482);
    return lerp(min, max, t);
}

// 2차원
float Random(float2 seed, float min, float max)
{
    float t = frac(sin(dot(seed, float2(73.867, 25.241))) * 39482.17593);
    return lerp(min, max, t);
}

/*********************************************************************
* Remap
**********************************************************************/
// input : 입력 값 / inRange : 기준 범위 / outRange : 변경 범위
float4 Remap(float4 input, float2 inRange, float2 outRange)
{
    return (outRange.y - outRange.x)/(inRange.y - inRange.x)
           * (input - inRange.x) + outRange.x;
}

// UV (0 ~ 1 범위)를 특정 범위(min ~ max)로 Remap하여 사용
float2 RemapUV(float2 uv, float2 min, float2 max)
{
    return float2(uv.x * (max.x - min.x) + min.x,
                  uv.y * (max.y - min.y) + min.y);
}

/*********************************************************************
* Smax : Smooth Max
**********************************************************************/
float Smax(float a, float b, float k)
{
    float h = clamp((b - a) / k + 0.5, 0.0, 1.0);
    return mix(a, b, h) + h * (1.0 - h) * k * 0.5;
}

