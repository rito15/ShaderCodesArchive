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
 * Basic Shapes
 **************************************************************************************************/
// 직사각형 : 좌하단, 우상단 정점 좌표
float Rect(float2 uv, float2 p1, float2 p2, float smoothness)
{
    float2 center = (p1 + p2) * 0.5;
    float  width  = (p2.x - p1.x) * 0.5;
    float  height = (p2.y - p1.y) * 0.5;
    
    float rect = smoothstep(width,   width - smoothness, abs(uv.x - center.x)); // 세로
         rect *= smoothstep(height, height - smoothness, abs(uv.y - center.y)); // 가로
    
    return rect;
}

/**************************************************************************************************
 * Digit Debug
 **************************************************************************************************/
// 기본 : 한 칸 채우기
float DigitSquare(float2 uv, float2 center, float unit)
{
    unit *= 0.5;
    float rect = 1.- step(unit + 0.0001, abs(uv.x - center.x));
         rect *= 1.- step(unit + 0.0001, abs(uv.y - center.y));
    return rect;
}

// 점
float DigitDot(float2 uv, float2 pivot, float unit)
{
    return DigitSquare(uv, pivot + unit * 0.5, unit);
}

// 마이너스
float DigitMinus(float2 uv, float2 pivot, float unit)
{
    float2 pivotPoint = pivot + unit * 0.5;
    return DigitSquare(uv, pivotPoint + unit * float2(0.0, 2.0), unit) +
           DigitSquare(uv, pivotPoint + unit * float2(1.0, 2.0), unit) +
           DigitSquare(uv, pivotPoint + unit * float2(2.0, 2.0), unit);
}

// 숫자 표현 - pivot : 좌측 하단 기준점, unit : 단위 길이, digit : 정수 1개
float Digit(float2 uv, float2 pivot, float unit, int digit)
{
    float2 pivotPoint = pivot + unit * 0.5;
    
    // Full Rect
    float dgRect = Rect(uv, pivot, pivot + unit * float2(3.0, 5.0), 0.0001);
    
    // Dots
    float dg00 = DigitSquare(uv, pivotPoint, unit);
    float dg01 = DigitSquare(uv, pivotPoint + unit * float2(0.0, 1.0), unit);
    float dg02 = DigitSquare(uv, pivotPoint + unit * float2(0.0, 2.0), unit);
    float dg03 = DigitSquare(uv, pivotPoint + unit * float2(0.0, 3.0), unit);
    float dg04 = DigitSquare(uv, pivotPoint + unit * float2(0.0, 4.0), unit);
    float dg10 = DigitSquare(uv, pivotPoint + unit * float2(1.0, 0.0), unit);
    float dg11 = DigitSquare(uv, pivotPoint + unit * float2(1.0, 1.0), unit);
    float dg12 = DigitSquare(uv, pivotPoint + unit * float2(1.0, 2.0), unit);
    float dg13 = DigitSquare(uv, pivotPoint + unit * float2(1.0, 3.0), unit);
    float dg14 = DigitSquare(uv, pivotPoint + unit * float2(1.0, 4.0), unit);
    float dg20 = DigitSquare(uv, pivotPoint + unit * float2(2.0, 0.0), unit);
    float dg21 = DigitSquare(uv, pivotPoint + unit * float2(2.0, 1.0), unit);
    float dg22 = DigitSquare(uv, pivotPoint + unit * float2(2.0, 2.0), unit);
    float dg23 = DigitSquare(uv, pivotPoint + unit * float2(2.0, 3.0), unit);
    float dg24 = DigitSquare(uv, pivotPoint + unit * float2(2.0, 4.0), unit);
    
    // Digit 0 ~ 9
    float digit0 = dgRect - dg11 - dg12 - dg13;
    float digit1 = dg10 + dg11 + dg12 + dg13 + dg14; //dg20 + dg21 + dg22 + dg23 + dg24;
    float digit2 = dgRect - dg03 - dg11 - dg13 - dg21;
    float digit3 = dgRect - dg01 - dg03 - dg11 - dg13;
    float digit4 = dgRect - dg00 - dg01- dg10 - dg11 - dg13 - dg14;
    
    float digit5 = dgRect - dg01 - dg11 - dg13 - dg23;
    float digit6 = dgRect - dg11 - dg13 - dg23;
    float digit7 = dgRect - dg00 - dg01 - dg10 - dg11- dg12 - dg13;
    float digit8 = dgRect - dg11 - dg13;
    float digit9 = dgRect - dg01 - dg11 - dg13;
    
    switch(digit)
    {
        case 0: return saturate(digit0);
        case 1: return saturate(digit1);
        case 2: return saturate(digit2);
        case 3: return saturate(digit3);
        case 4: return saturate(digit4);
        case 5: return saturate(digit5);
        case 6: return saturate(digit6);
        case 7: return saturate(digit7);
        case 8: return saturate(digit8);
        case 9: return saturate(digit9);
    }
    return 0.;
}

// 대상 숫자 리턴 - unit : 한 칸 단위, value : 대상 값, cipher : 소수부 출력 자릿수
float DebugValue(float2 uv, float2 pos, float unit, float value, int cipher)
{
    uv -= pos;
    
    float digits = 0.; // 결괏값
    float2 cursor = float2(0., 0.);// 현재 커서 위치
    float2 space  = float2(unit * 4., 0.); // 공백
    
    // 음수처리
    if(value < 0.)
    {
     	digits += DigitMinus(uv, cursor, unit);
        cursor += space;
        value = -value;
    }
    
    int   valueN = int(value); 	// 정수부
    float valueF = frac(value); // 소수부
    
    bool printOn = false;
    
    // 정수부가 0일 경우
    if(valueN == 0)
    {
     	digits += Digit(uv, cursor, unit, 0);
        cursor += space;
    }
    else
    {
        // 정수부 출력
        for(int div = 1000000000; div > 0; div /= 10)
        {
            int d = valueN / div;

            if(d > 0 || printOn)
            {
                printOn = true;
                digits += Digit(uv, cursor, unit, d);
                cursor += space;

                valueN -= (d * div);
            }
        }
    }
    
    // 소숫점
    if(cipher > 0)
    {
        digits += DigitDot(uv, cursor, unit);
        cursor += space * 0.5;
    }
    
    // 소수부 출력
    for(int i = 1; i <= cipher; i++)
    {
        int d = int(valueF / 0.1);
        digits += Digit(uv, cursor, unit, d);
        cursor += space;
        valueF = frac(valueF * 10.);
    }
    
    return digits;
}

// override : 소숫점 4자리 표현
float DebugValue(float2 uv, float2 pos, float unit, float value)
{
 	return DebugValue(uv, pos, unit, value, 4);   
}

// 색상값 표시 - RGB
float3 DebugRGB(float2 uv, float2 pos, float unit, float3 rgb)
{
    float digits = DebugValue(uv - float2(0., unit * 12.), pos, unit, rgb.r, 4);
         digits += DebugValue(uv - float2(0., unit * 6.),  pos, unit, rgb.g, 4);
         digits += DebugValue(uv,                          pos, unit, rgb.b, 4);
    
    return rgb * digits;
}

// 색상값 표시 - RGBA
float3 DebugRGBA(float2 uv, float2 pos, float unit, float4 rgba)
{
    float digits = DebugValue(uv - float2(0., unit * 18.), pos, unit, rgba.r, 4);
         digits += DebugValue(uv - float2(0., unit * 12.), pos, unit, rgba.g, 4);
         digits += DebugValue(uv - float2(0., unit * 6.),  pos, unit, rgba.b, 4);
         digits += DebugValue(uv,                          pos, unit, rgba.a, 4);
          
    return rgba.rgb * digits;
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
    
    float val = 29.1803;
    float3 rgb1 = float3(0.8, 0.65, 0.962);
    float4 rgba1 = float4(0.5, 0.861, 0.025, 0.9174);
    
    col += DebugValue(uv, float2(0.0, 0.01), 0.03, val);
    col += DebugRGB(uv, float2(0.1, 0.3), 0.02, rgb1);
    col += DebugRGBA(uv2, float2(0.5, -0.4), 0.05, rgba1);
    
    fragColor = vec4(col,1.0);
}
