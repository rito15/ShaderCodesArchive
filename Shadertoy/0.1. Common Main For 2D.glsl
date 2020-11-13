
// 0 : 그리드를 보여주지 않음 / 1 : 0.05 단위 / 2 : 0.1 단위
#define LEVEL_GRID_DEBUG 1

// 0 : 그리드 및 테두리를 보여주지 않음 / 1 : Shape 뒤에 보여주기 / 2 : Shape 앞에 보여주기
#define LEVEL_SHOW_GRID 1

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // UV ================================================================================================
    float2 uv  = fragCoord/iResolution.xy;				// 화면 전체를 0.0 ~ 1.0 UV로 사용
    float2 uv0 = uv;
    float2 uv1 = uv * 2.0 - 1.0;                        // 화면 전체를 -1.0~ 1.0 UV로 사용
    float2 uv2 = GetSquareUV(iResolution, fragCoord);	// 화면 중앙 정사각형 범위를 0.0 ~ 1.0 UV로 사용
    float2 uv3 = uv2 * 2.0 - 1.0;						// 화면 중앙 정사각형 범위를 -1.0~ 1.0 UV로 사용
    
    // Finals ============================================================================================
    float3 shp = float3(0.0);	// Shape
    float3 col = float3(1.0);	// Color
    float3 grd = float3(0.0);   // Debug Grids
    
    
    
    
    // Body ==============================================================================================
    float2  heartPos    = float2(0.0, 0.0);
    float2  heartSizeWH = float2(1.0, 1.0);
    float   heartBlur = 0.01;
    float2  uvHeart   = (uv3 - heartPos) / (heartSizeWH * float2(1.15, 0.97));
    float2  heartBase = float2(uvHeart.x, uvHeart.y - sqrt(abs(uvHeart.x)) * 0.7 + 0.18);
    float   heart = smoothstep(0.87, 0.87 - heartBlur, length(heartBase));
    
    
    
    
    // Apply Colors ======================================================================================
    shp += heart;
    
    // Debug Grids =======================================================================================
    float2 uvGrd = uv2;
    
    //grd += debugCenterLine(uvGrd); // 중심   디버그
    grd += debugOutLine(uvGrd);    // 테두리 디버그
    grd += debugGrid(uvGrd, 0.05 * float(LEVEL_GRID_DEBUG) );  // 그리드 디버그

    // ===================================================================================================
    fragColor = vec4(1.0);
    fragColor.rgb = shp * col;
    
    #if LEVEL_SHOW_GRID == 1
    
    fragColor.rgb += grd;
    
    #elif LEVEL_SHOW_GRID == 2
    
    float3 grdWB = float3(step(0.001, grd.r+grd.g+grd.b)); // 흑백 그리드
    fragColor.rgb = lerp(fragColor.rgb, grd, grdWB);
    
    #endif
}
