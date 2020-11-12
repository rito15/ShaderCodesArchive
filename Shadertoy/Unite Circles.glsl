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
 * Basic Shapes
 **************************************************************************************************/
// 원 : 중심좌표, 반지름
float Circle(float2 uv, float2 center, float radius, float smoothness)
{
    return smoothstep(radius, radius - smoothness, length(uv - center));
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
float Heart(float2 uv, float2 center, float size, float smoothness)
{
    float2  uvHeart   = (uv - center) / size * float2(1.15, 0.97);
    float2  heartBase = float2(uvHeart.x, uvHeart.y - sqrt(abs(uvHeart.x)) * 0.7 + 0.18);
    float heart = smoothstep(0.87, 0.87 - smoothness, length(heartBase));
    return heart;
}

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
    //float r1 = Random11(seed, 0.3, 0.6);
    //float k = atan( lerp(-1., 0., frac(iTime * r1) ) );
    //return k;
    
    float r1 = Random11(seed, 0.3, 0.6);
    float r2 = Random11(seed, 0.1, 0.9);
    float r3 = Random11(seed, 0.2, 0.8);
    
    float k = sin( iTime * r1 * r2 * r3 );
    return k;
}

float GetRadius(float seed)
{
    return Random11(seed, 0.2, 0.3) + sin(iTime)*0.02;
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
    uv3 = UvRotate(uv3, iTime*0.2);
    uv3 = UvPulse(uv3, 0.1, iTime * 10.0);
    uv3 = UvWave(uv3, 0.5, 0.5, 0.1, iTime * 5.0);
    //uv3 = UvVibrate(uv3, 1., -1., 0.50, iTime * 5.0);
    //uv3 = UvScatter(uv3, float2(1000.0));
    
    float seed = 0.01;
    float cSmoothness = 0.1;
    
    //uv2 = UvRotate(uv2, -iTime * 0.2 + length(uv));
    float c0 = Circle(uv3, float2(0., 0 ), 0.5, 0.1);
    
    float c1 =  Circle(uv2, float2(0.         ,  GetT(seed)),      GetRadius(seed), cSmoothness); seed += 0.01;
    float c2 =  Circle(uv2, float2(GetT(seed) ,  0         ),      GetRadius(seed), cSmoothness); seed += 0.01;
    float c3 =  Circle(uv2, float2(0.         , -GetT(seed)),      GetRadius(seed), cSmoothness); seed += 0.01;
    float c4 =  Circle(uv2, float2(-GetT(seed),  0         ),      GetRadius(seed), cSmoothness); seed += 0.01;
    float c5 =  Circle(uv2, float2( GetT(seed),  GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c6 =  Circle(uv2, float2( GetT(seed), -GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c7 =  Circle(uv2, float2(-GetT(seed),  GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c8 =  Circle(uv2, float2(-GetT(seed), -GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c9 =  Circle(uv2, float2( GetT(seed),  GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c10 = Circle(uv2, float2( GetT(seed), -GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c11 = Circle(uv2, float2(-GetT(seed),  GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c12 = Circle(uv2, float2(-GetT(seed), -GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c13 = Circle(uv2, float2( GetT(seed),  GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c14 = Circle(uv2, float2( GetT(seed), -GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c15 = Circle(uv2, float2(-GetT(seed),  GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c16 = Circle(uv2, float2(-GetT(seed), -GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c17 = Circle(uv2, float2( GetT(seed),  GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c18 = Circle(uv2, float2( GetT(seed), -GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c19 = Circle(uv2, float2(-GetT(seed),  GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    float c20 = Circle(uv2, float2(-GetT(seed), -GetT(seed*seed)), GetRadius(seed), cSmoothness); seed += 0.01;
    
    float circles = smax(c0,      c1, 1.0);
          circles = smax(circles, c2, 1.0);
          circles = smax(circles, c3, 1.0);
          circles = smax(circles, c4, 1.0);
    
          circles = smax(circles, c5, 1.0);
          circles = smax(circles, c6, 1.0);
          circles = smax(circles, c7, 1.0);
          circles = smax(circles, c8, 1.0);
    
          circles = smax(circles, c9,  1.0);
          circles = smax(circles, c10, 1.0);
          circles = smax(circles, c11, 1.0);
          circles = smax(circles, c12, 1.0);
    
          circles = smax(circles, c13, 1.0);
          circles = smax(circles, c14, 1.0);
          circles = smax(circles, c15, 1.0);
          circles = smax(circles, c16, 1.0);
    
          circles = smax(circles, c17, 1.0);
          circles = smax(circles, c18, 1.0);
          circles = smax(circles, c19, 1.0);
          circles = smax(circles, c20, 1.0);
    
    //circles = step(0.5, circles);
    
    float changeSmooth = sin(iTime) * 0.099;
    shp += smoothstep(0.8 + changeSmooth, 1.0, circles );
    
    // 색상 ==================================================================
    
    float gd = smoothstep(0. , 1.0, length(uv2));
    col = float3(gd, 1. - gd * cos(uv.y + iTime), sin(uv.x + iTime *2.) * 0.5 + 0.5);
    
    // 스크린 필터 ============================================================
    if(iMouse.z > 1.)
    {
        float2 mousePos = iMouse.xy / iResolution.xy;
        mousePos = mousePos * 2. - 1.;
        
    	shp *= FilterMosaic(uv, 100. * length(mousePos) + 10., sin(iTime * 10.) * 0.05 + 0.5);
        
        //shp = float3(1.);
        //col = float3(1.);
        //col *= smoothstep(0.5, 1.0, 1. - length(uv - (mousePos + 1.) * 0.5));
    }
    
    // =========================================================================
    fragColor = vec4(shp * col,1.0);
}
