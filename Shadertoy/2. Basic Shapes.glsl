
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

// 이등변삼각형
float Triangle(float2 uv, float2 pos, float2 size, float smoothness)
{
    float center = 0.5; // 무게중심 맞출 경우 :  2.0/3.0;
    
    float2  uvTri = (uv - pos) / (size * 2.0);
    float tri = smoothstep(center + smoothness,    center - smoothness,    uvTri.y + abs(uvTri.x * 2.));
         tri *= smoothstep(center - smoothness*.5, center + smoothness*.5, uvTri.y + 1.);
    return tri;
}

// 정삼각형
float ETriangle(float2 uv, float2 pos, float size, float smoothness)
{
    float center = 0.5; // 무게중심 맞출 경우 :  2.0/3.0;
    float2  uvTri = (uv - pos) / (size * 2.0);
    float eqTri = smoothstep(center + smoothness,    center - smoothness,    uvTri.y + abs(uvTri.x * 2.));
         eqTri *= smoothstep(center - smoothness*.5, center + smoothness*.5, uvTri.y + 1.);
    return eqTri;
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

// 물방울
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
    float2  uvHeart   = (uv - center) / (size * float2(1.15, 0.97));
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

// 나선 : Spiral

/**************************************************************************************************
 * Calc Functions 
 **************************************************************************************************/
// Smooth Max
float smax(float a, float b, float k)
{
    float h = clamp((b - a) / k + 0.5, 0.0, 1.0);
    return mix(a, b, h) + h * (1.0 - h) * k * 0.5;
}

// Smooth Min
float smin(float a, float b, float k)
{
	float h = clamp( 0.5 + 0.5 * (b - a) / k, 0.0, 1.0 );
	return lerp(b, a, h) - k * h * (1.0 - h);
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

// 꿀렁꿀렁 - a : x꿀렁, b : y꿀렁, c : 꿀렁 범위 / t : 시간
float2 UvWave(float2 uv, float a, float b, float c, float t)
{
    float x = abs(uv.x) * a;
    float y = abs(uv.y) * b;
    float k;
    
    k = sin(x * y + t); // 기본
    //k *= cos(x *b + cos(t)*0.5) * 0.5 + 0.5; 
    
    float kkc = abs(k * k * c);
    float w1 = 1. + kkc * a;
    float w2 = 1. + kkc * b;
    return float2(uv.x * w1, uv.y / w2);
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
 * Screen Filter Functions 
 **************************************************************************************************/
// 모자이크
float FilterMosaic(float2 uv, float scale, float smoothness)
{
    float2 uv2 = frac((uv - float2(0.5, 0.5)) * scale);
    float2 mBase = uv2 - float2(0.5, 0.5);
    float mosaic = smoothstep(0.5, 0.5 - smoothness, length(mBase));
    return mosaic;
}

/**************************************************************************************************
 * Functions 
 **************************************************************************************************/

float Random11(float seed, float min, float max)
{
    float t = frac(sin(seed * 13.421 + 23.512) * 17593.39482);
    return lerp(min, max, t);
}

float GetT(float seed)
{
    float r1 = Random11(seed, 0.3, 0.6);
    
    float k = atan( lerp(-1., 0., frac(iTime * r1) ) );
    return k;
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
    
    float3 shp = float3(0.); // 최종 모양
    float3 col = float3(1.); // 최종 컬러
    // => 최종 결과 = shp * col
    
    // uv2 이동
    float2 uvOffset = float2(0.0, 0.0);
    
    // uv Remap : 0. ~ 1. => -1. ~ 1.
    float2 uv2 = uv *2. - 1. - uvOffset;
    
    // 특정 UV 적용
    float2 uv3 = uv2;
    //uv3 = UvTile(uv3, float2(2., 2.), float2(0.5));
    //uv3 = UvRotate(uv3, iTime);
    //uv3 = UvPulse(uv3, 0.01, iTime * 10.0);
    uv3 = UvWave(uv3, 0.5, 0.5, 0.1, iTime * 5.0);
    //uv3 = UvVibrate(uv3, 1., -1., 0.50, iTime * 5.0);
    //uv3 = UvScatter(uv3, float2(1000.0));
    
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
    float rect1 = Rect(uv2, float2(0., 0.), float2(1.0, 1.0), 0.1);
    float rect2 =  RectP(uv2, float2(0.2, 0.2), float2(0.4, 0.6), 0.01);
    
    // 이등변삼각형
    float triangle = Triangle(uv2, float2(0.0, 0.0), float2(0.4, 0.4), 0.1);
    
    // 정삼각형
    float eTriangle = ETriangle(uv2, float2(0.0, 0.0), 1.0, 0.01);
    
    // 원, 타원
    float circle1 = Circle(uv2, float2(0., 0.), 0.2, 0.01);
    float circle2 = Circle(uv2, float2(0.3, 0.6), float2(0.3, 0.4), 0.01);
    float circle3 = CircleP(uv2, float2(-0.2, -0.4), float2(0.4, 0.2), 0.1);
    
    // 물방울 - UV, center, size, smoothness
    float drop = Drop(uv2, float2(0.0, 0.0), float2(0.4, 0.8), 0.01);
    
    // 하트 : uv, center, size, smoothness
    float heart = Heart(uv3, float2(0.,0.), float2(1.0, 1.0), 0.05);
    float heartShade = Heart(uv3, float2(0.,0.), float2(1.0, 1.0), 0.06);
    float heartLight = smoothstep(1.0, -0.5, length(uv3 - float2(-0.25, 0.5))) * 0.6 + 0.1;
    
    // 사인그래프 : uv, pos, frequency, amplitude, thickness, smoothness
    float sWave = SineWave(uv2, float2(0., 0.4), 5., 0.2, 0.2, 0.5);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 별(십자) : TODO
    float crossStarSize = 0.2;
    float crossStarBlur = 0.2;
    float crossStar = smoothstep(crossStarSize, crossStarSize - crossStarBlur, abs(uv2.x * uv2.y) * 5.);
    
    // 모양 ==================================================================
    
    shp += heart;
    
    
    // 색상 ==================================================================
    
    //col *= uv.yxx * 2.0;
    
    float gd = smoothstep(0. , 1.0, length(uv2));
    col = float3(gd, 1. - gd * cos(uv.y + iTime), sin(uv.x + iTime))
        * heartShade
        * heartLight;
    
    
    // 스크린 필터 ============================================================
    
    //col *= FilterMosaic(uv, 100., sin(iTime * 10.) * 0.1 + 0.5);
    
    
    // 디버그 옵션 ============================================================
    
    float3 dbg = float3(0.);
    dbg += debugCenterLine(uv); // 중심   디버그
    dbg += debugOutLine(uv);    // 테두리 디버그
    dbg += debugGrid(uv, 0.1);  // 그리드 디버그 : uv
    //dbg += debugGrid(uv, 0.05); // 그리드 디버그 : uv2
    
    // =========================================================================
    fragColor = vec4(shp * col + (1.-shp) * dbg,1.0);
}
