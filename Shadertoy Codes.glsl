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
 * Basic Shapes
 **************************************************************************************************/
// 점
float Point(float2 uv, float2 p)
{
    return smoothstep(0.03, 0.02, length(uv - p));
}

// 선분 : 시작점, 끝점, 굵기
float Line(float2 uv, float2 p1, float2 p2, float thickness, float smoothness)
{
    // zero div 회피
    p1 += 0.000001;
    p2 -= 0.000001;
    
    // 두께 반감
    thickness *= 0.5;
    
    // 범위제한
    thickness = max(0.005, thickness);
    smoothness = clamp(smoothness, 0.0001, 1.);
    
    float w = abs(p2.x - p1.x);
    float h = abs(p2.y - p1.y);
    float len = sqrt(w*w + h*h); // 직선 길이(빗변 이용)
    
    float slope = (p2.y - p1.y)/(p2.x - p1.x); 	// 기울기
    float2 center = (p2 + p1) * 0.5; 			// 중심점
    
    // 1. 두께 제한
    // 기울기가 변해도 굵기, 부드러움이 유지되도록 계산
    // smoothstep 내에 적용되는 실제 thickness는 빗변이 아니고 width 값이므로
    // (len / width)를 곱해줌으로써 빗변 길이가 실제 thickness로 적용되도록 해줌
    float th = thickness * (len / w);
    float sm = smoothness * (len / w);
    float line = smoothstep(th, th - sm, abs((uv.x - center.x) * slope - (uv.y - center.y)));
    
    // 2. 길이 제한
    float revTh = (len * 0.5) * (len / h); // 제한선 두께
    float revSm = smoothness * (len / h);  // 제한선 스무딩
    line *= smoothstep(revTh , revTh - revSm, abs(-(uv.x - center.x) / slope - (uv.y - center.y)));
    
 	return line;   
}

// Straight Vertical Line
// 세로 직선 : x좌표, 굵기
float SVLine(float2 uv, float posX, float thickness, float smoothness)
{
    return smoothstep(thickness * 0.5, thickness * 0.5 - smoothness, abs(uv.x - posX));
}

// 세로 쌍직선 : 중심 x좌표, 두 직선 사이 거리, 굵기
float SDVLine(float2 uv, float posX, float dist, float thickness, float smoothness)
{
    return smoothstep(thickness * 0.5, thickness * 0.5 - smoothness, abs(abs(uv.x - posX) - dist * 0.5));
}

// 직사각형 : 중심점, 너비, 높이
float Rect(float2 uv, float2 center, float width, float height, float smoothness)
{
    width *= 0.5;
    height *= 0.5;
    
    float rect = smoothstep(width,   width - smoothness, abs(uv.x - center.x)); // 세로
         rect *= smoothstep(height, height - smoothness, abs(uv.y - center.y)); // 가로
    
    return rect;
}

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

// 원 : 중심좌표, 반지름
float Circle(float2 uv, float2 center, float radius, float smoothness)
{
    return smoothstep(radius, radius - smoothness, length(uv - center));
}

// 원(타원) : 중심좌표, 너비, 높이
float Circle(float2 uv, float2 center, float width, float height, float smoothness)
{
    return smoothstep(1., 1. - smoothness, length((uv - center) / float2(width, height) * 2.));
}

// 원(타원) : 좌하단 정점, 우상단 정점
float Circle(float2 uv, float2 p1, float2 p2, float smoothness)
{
    float2 center = (p2 + p1) * 0.5;
    float width  = (p2.x - p1.x);
    float height = (p2.y - p1.y);
    
    return smoothstep(1., 1. - smoothness, length((uv - center) / float2(width, height) * 2.));
}

// 물방울 : TODO
float Drop(float2 uv, float2 center, float width, float height, float smoothness)
{
    center = float2(0.2, 0.2);
    width = 0.4;
    height = 0.6;
    smoothness = 0.01;
    
    float2 uvDrop = uv - center;
    
    float2  dropBase = float2(uvDrop.x * 2.,
                          uvDrop.y + (uvDrop.x * (acos(cos(uvDrop.x)) + 2.) * sin(uvDrop.x)));
    return smoothstep(0.5, 0.5 - smoothness, length(dropBase));
}

/**************************************************************************************************
 * Digits
 **************************************************************************************************/
// 기본 : 한 칸 채우기
float DigitSquare(float2 uv, float2 center, float width)
{
    width *= 0.5;
    
    float rect = 1.- step(width, abs(uv.x - center.x));
         rect *= 1.- step(width, abs(uv.y - center.y));
    return rect;
}

//==================================================================================================

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
    
    //////////////////////////////////////// UV ////////////////////////////////////////
    
    // 타일 uv
    float tileSize = 4.;
    float2 uvTile = fract(uv * tileSize) - .5;
    
    // 시간에 따라 회전하는 uv
    float rot = -_Time.y;
    float2x2 rotMat = float2x2(cos(rot), sin(rot),
                              -sin(rot), cos(rot)); // 회전행렬
    float2 uvRot = mul(rotMat, uv2);
    
    // 박동하는 UV
    float pulseSpeed = 5.0; // 박동속도
    float pulseRange = 0.2; // 박동범위
    float2 uvPulse = uv2 * (1. + sin(_Time.y * pulseSpeed)* pulseRange);
    
    // TODO : 일렁이는 uv
    
    // 특정 UV 적용
    
    //uv2 = uvTile;
    //uv2 = uvRot;
    //uv2 = uvPulse;
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 선분
    
    float2 linePointA = float2(-0.2, 0.4);
    float2 linePointB = float2(0.4, -0.2);
    float line = Line(uv2, linePointA, linePointB, 0.1, 0.);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 세로 직선
    float svLine = SVLine(uv2, 0.65, 0.1, 0.001);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 세로 쌍직선
    float sdvLine = SDVLine(uv2, 0.4, 0.4, 0.1, 0.01);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 사각형
    float rect1 = Rect(uv2, float2(-0.3, -0.2), float2(0.4, 0.5), 0.01);
    float rect2 = Rect(uv2, float2(0.2, 0.2), 0.4, 0.2, 0.01);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 원, 타원
    float circle1 = Circle(uv2, float2(-0.3, -0.4), 0.2, 0.01);
    float circle2 = Circle(uv2, float2(0.3, 0.6), 0.3, 0.4, 0.01);
    float circle3 = Circle(uv2, float2(-0.2, -0.4), float2(0.4, 0.2), 0.1);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 물방울 - TODO : 상단 뾰족하게
    float drop = Drop(uv2, float2(0.2, 0.2), 0.4, 0.6, 0.01);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 하트
    float2  heartPos    = float2(0.0, 0.0);
    float2  heartSizeWH = float2(0.4, 0.4);
    float heartBlur = 0.01;
    float2  uvHeart   = (uv2 - heartPos) / (heartSizeWH * float2(1.15, 0.97));
    float2  heartBase = float2(uvHeart.x, uvHeart.y - sqrt(abs(uvHeart.x)) * 0.7 + 0.18);
    float heart = smoothstep(0.87, 0.87 - heartBlur, length(heartBase));
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 정삼각형
    float2  eqTriPos = float2(0.0, 0.0);
    float eqTriSize = 0.5;
    float eqTriCenter = 0.5; // 무게중심 맞출 경우 :  2.0/3.0;
    float eqTriBlur = 0.02;
    float2  uvEqTri = (uv2 - eqTriPos) / (eqTriSize * 2.0);
    float eqTri = smoothstep(eqTriCenter + eqTriBlur, eqTriCenter - eqTriBlur, uvEqTri.y + abs(uvEqTri.x * 2.));
         eqTri *= smoothstep(eqTriCenter - eqTriBlur*.5, eqTriCenter + eqTriBlur*.5, uvEqTri.y + 1.);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 이등변삼각형
    float2  triPos    = float2(0.0, 0.0);
    float2  triSizeWH = float2(0.6, 0.4);
    float triCenter = 0.5; // 무게중심 맞출 경우 :  2.0/3.0;
    float triBlur = 0.01;
    float2  uvTri = (uv2 - triPos) / (triSizeWH * 2.0);
    float tri = smoothstep(triCenter + triBlur, triCenter - triBlur, uvTri.y + abs(uvTri.x * 2.));
         tri *= smoothstep(triCenter - triBlur*.5, triCenter + triBlur*.5, uvTri.y + 1.);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 별(십자) : TODO
    float crossStarSize = 0.2;
    float crossStarBlur = 0.2;
    float crossStar = smoothstep(crossStarSize, crossStarSize - crossStarBlur, abs(uv2.x * uv2.y));
    
    ////////////////////////////////////////////////////////////////////////////////////
    
    // 최종 색상
    //col += drop;
    
    
    
    float2 dgUnit = float2(1., 1.) * 0.1;
    float2 dgUnith = dgUnit * 0.5;
    
    // Dots
    float dg00 = DigitSquare(uv, dgUnith, dgUnit.x);
    float dg01 = DigitSquare(uv, dgUnith + dgUnit * float2(0.0, 1.0), dgUnit.x);
    float dg02 = DigitSquare(uv, dgUnith + dgUnit * float2(0.0, 2.0), dgUnit.x);
    float dg03 = DigitSquare(uv, dgUnith + dgUnit * float2(0.0, 3.0), dgUnit.x);
    float dg04 = DigitSquare(uv, dgUnith + dgUnit * float2(0.0, 4.0), dgUnit.x);
    
    float dg10 = DigitSquare(uv, dgUnith + dgUnit * float2(1.0, 0.0), dgUnit.x);
    float dg11 = DigitSquare(uv, dgUnith + dgUnit * float2(1.0, 1.0), dgUnit.x);
    float dg12 = DigitSquare(uv, dgUnith + dgUnit * float2(1.0, 2.0), dgUnit.x);
    float dg13 = DigitSquare(uv, dgUnith + dgUnit * float2(1.0, 3.0), dgUnit.x);
    float dg14 = DigitSquare(uv, dgUnith + dgUnit * float2(1.0, 4.0), dgUnit.x);
    
    float dg20 = DigitSquare(uv, dgUnith + dgUnit * float2(2.0, 0.0), dgUnit.x);
    float dg21 = DigitSquare(uv, dgUnith + dgUnit * float2(2.0, 1.0), dgUnit.x);
    float dg22 = DigitSquare(uv, dgUnith + dgUnit * float2(2.0, 2.0), dgUnit.x);
    float dg23 = DigitSquare(uv, dgUnith + dgUnit * float2(2.0, 3.0), dgUnit.x);
    float dg24 = DigitSquare(uv, dgUnith + dgUnit * float2(2.0, 4.0), dgUnit.x);
    
    // Digit 0 ~ 9
    float digit0 = dg00 + dg01 + dg02 + dg03 + dg04 +
                   dg10 +                      dg14 + 
                   dg20 + dg21 + dg22 + dg23 + dg24;
    
    float digit1 = dg20 + dg21 + dg22 + dg23 + dg24;
    
    float digit2 = dg00 + dg01 + dg02 +        dg04 +
                   dg10 +        dg12 +        dg14 + 
                   dg20 +        dg22 + dg23 + dg24;
    
    float digit3 = dg00 +        dg02 +        dg04 +
                   dg10 +        dg12 +        dg14 + 
                   dg20 + dg21 + dg22 + dg23 + dg24;
    
    float digit4 =               dg02 + dg03 + dg04 +
                                 dg12 +               
                   dg20 + dg21 + dg22 + dg23 + dg24;
    
    float digit5 = dg00 +        dg02 + dg03 + dg04 +
                   dg10 +        dg12 +        dg14 + 
                   dg20 + dg21 + dg22 +        dg24;
    
    float digit6 = dg00 + dg01 + dg02 + dg03 + dg04 +
                   dg10 +        dg12 +        dg14 + 
                   dg20 + dg21 + dg22 +        dg24;
    
    float digit7 =               dg02 + dg03 + dg04 +
                                               dg14 + 
                   dg20 + dg21 + dg22 + dg23 + dg24;
    
    float digit8 = dg00 + dg01 + dg02 + dg03 + dg04 +
                   dg10 +        dg12 +        dg14 + 
                   dg20 + dg21 + dg22 + dg23 + dg24;
    
    float digit9 = dg00 +        dg02 + dg03 + dg04 +
                   dg10 +        dg12 +        dg14 + 
                   dg20 + dg21 + dg22 + dg23 + dg24;
    
    
    float digitDot = dg10;
    
    col += digit9;
    
    // 디버그 옵션
    col += debugCenterLine(uv); // 중심   디버그
    col += debugOutLine(uv);    // 테두리 디버그
    col += debugGrid(uv, 0.1);  // 그리드 디버그 : uv
    //col += debugGrid(uv, 0.05); // 그리드 디버그 : uv2
    
    fragColor = float4(col,1.0);
}
