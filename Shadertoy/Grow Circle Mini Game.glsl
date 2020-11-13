#define CIRCLE 0
#define HEART 1
#define DROP 2
#define RECT 3

/**************************************************************************************************
 * Options
 **************************************************************************************************/

#define CIRCLE_COUNT 20
#define SHAPE_MODE   CIRCLE

bool APPLY_SHADOW = false;

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
    
    // uv Remap : 0. ~ 1. => -1. ~ 1.
    float2 uv2 = uv *2. - 1.;
    
    
    // == - ========================================================
    
    float2 mousePos = ((iMouse.xy / iResolution.xy) * adjMul - adjSub) * 2. - 1.;
    
    float2 uvHero;
    uvHero = uv2 - mousePos;
    uvHero = UvPulse(uvHero, 0.05, iTime * 10.0);
    uvHero = UvWave(uvHero, 0.5, 0.5, 0.1, iTime * 5.0);
    //uvHero = UvRotate(uvHero, iTime*0.2);
    //uvHero = UvVibrate(uvHero, 10., 10., 0.1, iTime * 5.0);
    //uvHero = UvScatter(uvHero, float2(35.0));
    
    float rHero = 0.2;
    
    // Arrays
    float[CIRCLE_COUNT]  arrS; // Seed
    float[CIRCLE_COUNT]  arrR; // Radius
    float2[CIRCLE_COUNT] arrP; // Position
    float[CIRCLE_COUNT]  arrD; // Distance Between Circle with Mouse
    float[CIRCLE_COUNT]  arrT; // Touched?  (닿았는지 여부)
    float[CIRCLE_COUNT]  arrC; // Contact Rate (접촉률)
    
    float[CIRCLE_COUNT]  arrCircle; // Circles
    float3[CIRCLE_COUNT] arrColor;  // Colors
    float[CIRCLE_COUNT]  arrShadow;
    
    float totalContact = 0.; // 접촉률 총합
    
    for(int i = 0; i < CIRCLE_COUNT; i++)
    {
        // Init Arrays
        arrS[i] = float(i) * 123. + 0.456 * iDate.z;
        arrR[i] = GetRandomRadius(arrS[i]);
        arrP[i] = GetRandomPos(arrS[i], iTime);   
        arrD[i] = length(arrP[i] - mousePos) - (rHero) * 0.4;
        arrT[i] = step(arrD[i], arrR[i]);
        arrC[i] = arrT[i] * (arrR[i] - arrD[i]);
        
        // Generate Circles
        arrCircle[i] = Circle(uv2, arrP[i], arrR[i] - arrC[i], 0.1);
        
        // Generate Shadows
        arrShadow[i] = smoothstep(1.0, 0.0, length(uv2 - arrP[i]) + (1. - arrR[i]) ) * 1.2;
        
        totalContact += arrC[i];
    }
    
    
    // Grow Hero Circle
    rHero = rHero + totalContact * 0.5;
    float debug = DebugValue(uv2, float2(-1.75, -0.95), 0.02, rHero, 2);
    
    // Generate Hero Circle
    float cHero = 
        
    #if (SHAPE_MODE == CIRCLE)
    
    Circle(uvHero, float2(0.), rHero, 0.1);
    
    #elif (SHAPE_MODE == HEART)
    
    lerp(Circle(uvHero, float2(0.), rHero, 0.1),
         Heart(uvHero, float2(0.), float2(rHero), 0.5),
         (rHero - 0.2) * 2.5
        );
    
    #elif (SHAPE_MODE == DROP)
    
    lerp(Circle(uvHero, float2(0.), rHero, 0.1),
         Drop(uvHero, float2(0.), float2(rHero*2.0, rHero*4.0), 0.3),
         saturate((rHero - 0.2) * 10.)
        );
    
    #elif (SHAPE_MODE == RECT)
    
    lerp(Circle(uvHero, float2(0.), rHero, 0.1),
         Rect(uvHero, float2(0.), float2(rHero*2.0), 0.2),
         (rHero - 0.2) * 2.5
        );
    
    #endif
    
    // Shadow
    float shdHero = smoothstep(1.0, 0.87, length(uv2 - mousePos) + (1. - rHero) );
    
    // Set Color of Hero
    float3 colHero = cHero * float3(
        R11(sin(iTime*1.), 0.5, 0.9),
        R11(sin(iTime*2.), 0.2, 0.9),
        R11(sin(iTime*3.), 0.2, 0.9));
    
    if(APPLY_SHADOW)
    	colHero *= shdHero;
        
    // Set Colors of Circles
    for(int i = 0; i < CIRCLE_COUNT; i++)
    {
        arrColor[i] = arrCircle[i] * float3(
        R11(cos(sin(arrS[i]) * 22.), 0.2, 1.0),
        R11(cos(sin(arrS[i]) * 33.), 0.2, 1.0),
        R11(cos(sin(arrS[i]) * 44.), 0.2, 1.0));
        
        if(APPLY_SHADOW)
        	arrColor[i] += arrShadow[i];
    }
    
    // Unite Circles
    float circles;
    if(CIRCLE_COUNT > 0)
    	circles = smax(cHero,   arrCircle[0], 1.0);
    
    for(int i = 1; i < CIRCLE_COUNT; i++)
    {
        circles = smax(circles, arrCircle[i], 1.0);
    }
    
    // Smoothness
    float changeSmooth = sin(iTime) * 0.099;
    shp += smoothstep(0.9 + changeSmooth, 1.0, circles );
    
    // Apply Colors
    float3 mCol = colHero;
    
    if(CIRCLE_COUNT > 0)
    	mCol = max(colHero, arrColor[0]);
    
    for(int i = 1; i < CIRCLE_COUNT; i++)
    {
        mCol = max(mCol, arrColor[i]);
    }
    
    col *= mCol;
    
    // =========================================================================
    fragColor = vec4(shp * col + debug,1.0);
}
