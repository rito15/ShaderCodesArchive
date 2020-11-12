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

// 직사각형 : 중심점, 사이즈(너비, 높이)
float Rect(float2 uv, float2 center, float2 size, float smoothness)
{
    size *= 0.5;
    
    float rect = smoothstep(size.x, size.x - smoothness, abs(uv.x - center.x)); // 세로
         rect *= smoothstep(size.y, size.y - smoothness, abs(uv.y - center.y)); // 가로
    
    return rect;
}

// 직사각형 : 좌하단, 우상단 정점 좌표
float RectP(float2 uv, float2 p1, float2 p2, float smoothness)
{
    float2 center = (p1 + p2) * 0.5;
    float2 size = (p2 - p1) * 0.5;
    
    float rect = smoothstep(size.x, size.x - smoothness, abs(uv.x - center.x)); // 세로
         rect *= smoothstep(size.y, size.y - smoothness, abs(uv.y - center.y)); // 가로
    
    return rect;
}

// 원 : 중심좌표, 반지름
float Circle(float2 uv, float2 center, float radius, float smoothness)
{
    return smoothstep(radius, radius - smoothness, length(uv - center));
}

// 원(타원) : 중심좌표, 사이즈(너비, 높이)
float Circle(float2 uv, float2 center, float2 size, float smoothness)
{
    return smoothstep(1., 1. - smoothness, length((uv - center) / size * 2.));
}

// 원(타원) : 좌하단 정점, 우상단 정점 좌표
float CircleP(float2 uv, float2 p1, float2 p2, float smoothness)
{
    float2 center = (p2 + p1) * 0.5;
    float2 size = (p2 - p1) * 2.;
    
    return smoothstep(1., 1. - smoothness, length((uv - center) / size));
}

// 물방울 : TODO
float Drop(float2 uv, float2 center, float2 size, float smoothness)
{
    float2 uvDrop = (uv - center) / (size * float2(1., 0.5));
    uvDrop = -uvDrop;
    
    float k = max(min(-0.45 * (uvDrop.y - 0.5), 1.), 0.); // k = max(min(-y, 1), 0) 변형
    float s = k * k * (2.5 - 2. * k);                     // s = k^2(3 - 2k) 변형
    float dropBase = abs(uvDrop.x) + s;
    float drop = smoothstep(0.5, 0.5 - smoothness, dropBase);
    
    // 상하 가로로 자르기
    float dropClip = smoothstep(1.0, 0.5, abs(uvDrop.y + 0.2));
    drop *= dropClip;
    
    // 물방울 하단부 원
    float dropCircle = smoothstep(0.5, 0.5 - smoothness, length(uvDrop - float2(0., 0.5)));
    dropCircle *= 1. - dropClip;
    drop += dropCircle;
    
    drop = smoothstep(0., 1., drop);
    
    return drop;
}

// 하트
float Heart(float2 uv, float2 center, float2 size, float smoothness)
{
    float2  uvHeart   = (uv - center) / size * float2(1.15, 0.97);
    float2  heartBase = float2(uvHeart.x, uvHeart.y - sqrt(abs(uvHeart.x)) * 0.7 + 0.18);
    float heart = smoothstep(0.87, 0.87 - smoothness, length(heartBase));
    return heart;
}

// 사인 그래프
float SineWave(float2 uv, float2 pos, float frequency, float amplitude, float thickness, float smoothness)
{
    float2 suv = uv - pos;
    float sBase = abs(sin(suv.x * frequency) + suv.y / amplitude);
    return smoothstep(thickness + smoothness, thickness - smoothness, sBase);
}

// 세잎클로버

// 네잎클로버

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
    float y = abs(uv.y) * b;
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
    uv2 = UvVibrate(uv2, 1., -1., 0.50, iTime * 5.0);
    uv2 = UvScatter(uv2, float2(100.0));
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 선분
    float2 linePointA = float2(-0.2, 0.4);
    float2 linePointB = float2(0.4, -0.2);
    float line = Line(uv2, linePointA, linePointB, 0.1, 0.);
    
    // 세로 직선
    float svLine = SVLine(uv2, 0.65, 0.1, 0.001);
    
    // 세로 쌍직선
    float sdvLine = SDVLine(uv2, 0.4, 0.4, 0.1, 0.01);
    
    // 사각형
    float rect1 = Rect(uv2, float2(0., 0.), float2(1.0, 1.0), 0.01);
    float rect2 =  RectP(uv2, float2(0.2, 0.2), float2(0.4, 0.6), 0.01);
    
    // 원, 타원
    float circle1 = Circle(uv2, float2(0., 0.), 0.2, 0.01);
    float circle2 = Circle(uv2, float2(0.3, 0.6), float2(0.3, 0.4), 0.01);
    float circle3 = CircleP(uv2, float2(-0.2, -0.4), float2(0.4, 0.2), 0.1);
    
    // 물방울 - UV, center, size, smoothness
    float drop = Drop(uv2, float2(0.0, 0.0), float2(0.4, 0.8), 0.01);
    
    // 하트 : uv, center, size, smoothness
    float heart = Heart(uv2, float2(0.,0.), float2(1.6, 0.8), 0.05);
    
    // 사인그래프 : uv, pos, frequency, amplitude, thickness, smoothness
    float sWave = SineWave(uv2, float2(0., 0.4), 5., 0.2, 0.2, 0.5);
    
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
    
    //col += heart;
    
    //col *= uv.xyx;
    
    col += rect1;
    
    // 디버그 옵션
    //col += debugCenterLine(uv); // 중심   디버그
    //col += debugOutLine(uv);    // 테두리 디버그
    //col += debugGrid(uv, 0.1);  // 그리드 디버그 : uv
    //col += debugGrid(uv, 0.05); // 그리드 디버그 : uv2
    
    fragColor = vec4(col,1.0);
}
