
// DEFINITIONS : Unity Compatibility
#define float2   vec2
#define float3   vec3
#define float4   vec4
#define float2x2 mat2
#define float3x3 mat3
#define float4x4 mat3
#define frac(x)     fract(x)
#define lerp(a,b,t) mix(a,b,t)
#define atan2(y,x)  atan(x,y)
#define tex2D(s,t)  texture(s,t)

float2 mul(float2x2 m, float2 v)
{
	return v * m;   
}

// DEBUG Functions =================================================================================

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
float3 debugGrid(float2 uv)
{
    // 0.1마다 그리드 디버그
    float grid = 0.;
    float2 gridXY = float2(0.);
    for(float f = 0.1; f < 1.0; f += 0.1)
    {
        // 가로선
        if(uv.y >= f - 0.002 && uv.y <= f + 0.002 && uv.x > 0. && uv.x < 1.)
        {
            grid = 1.;
            gridXY = uv + 0.4; 
        }
        
        // 세로선
        if(uv.x >= f - 0.002 && uv.x <= f + 0.002)
        {
            grid = 1.;
            gridXY = uv + 0.4;
        }
        
    }
    
    return float3(0., grid, 0.);
    //return float3(gridXY, 0.);
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
    
    // 특정 UV 적용
    
    //uv2 = uvTile;
    //uv2 = uvRot;
    uv2 = uvPulse;
    
    ////////////////////////////////////////////////////////////////////////////////////
    
    // 직선
    float linePosX = 0.5;        // 직선 중심의 x 좌표
    float lineThickness = 0.1;   // 직선 굵기
    float lineBlur = 0.01;       // 직선 평활도
    float line = smoothstep(lineThickness, lineThickness - lineBlur,
                            abs(uv2.x - linePosX));
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 쌍직선
    float dLinePosX = 0.5;         // 중심 x 좌표
    float dLineThickness = 0.1;    // 쌍직선 굵기
    float dLineBlur = 0.001;       // 쌍직선 블러 정도
    float dLineDistance = 0.2;     // 직선 사이 거리
    float dLine = smoothstep(dLineThickness, dLineThickness - dLineBlur, 
                             abs(abs(uv2.x - dLinePosX) - dLineDistance * 2.));
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 사각형
    float2  rectPos    = float2(0.0, 0.0); // 중심 위치
    float2  rectSizeWH = float2(0.6, 0.4); // 너비, 높이
    float rectBlur   = 0.01;
    float rect = smoothstep(rectSizeWH.x, rectSizeWH.x - rectBlur, abs(uv2.x - rectPos.x));
         rect *= smoothstep(rectSizeWH.y, rectSizeWH.y - rectBlur, abs(uv2.y - rectPos.y));
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 원
    float2  circlePos  = float2(0.0, 0.0);
    float circleSize = 0.5;
    float circleBlur = 0.1;
    float circleBase = 1. - length((uv2 - circlePos) / circleSize);
    float circle = smoothstep(.0, circleBlur, circleBase);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 타원
    float2  ellipsePos    = float2(0.0, 0.0);
    float2  ellipseSizeWH = float2(0.4, 0.3);
    float ellipseBlur = 0.01;
    float ellipseBase = 1. - length((uv2 - ellipsePos) / ellipseSizeWH);
    float ellipse = smoothstep(.0, ellipseBlur, ellipseBase);
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 물방울 - TODO : 상단 뾰족하게
    float2  dropPos    = float2(0.0, 0.0);
    float2  dropSizeWH = float2(0.3, 0.3);
    float dropBlur = 0.05;
    float2  uvDrop   = (uv2 - dropPos) / (dropSizeWH * 2.);
    float2  dropBase = float2(uvDrop.x * 2.,
                          uvDrop.y + ((uvDrop.x) * (cos(uvDrop.x) + 2.) * sin(uvDrop.x)));
    float drop = smoothstep(0.5, 0.5 - dropBlur, length(dropBase));
    
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
    col += heart;
    
    // 디버그 옵션
    col += debugCenterLine(uv); // 중심   디버그
    col += debugOutLine(uv);    // 테두리 디버그
    col += debugGrid(uv);       // 그리드 디버그
    
    fragColor = float4(col,1.0);
}
