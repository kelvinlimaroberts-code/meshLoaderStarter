#include "Constants.hlsl"

//vertex shader transforms incoming triangle vertices
VertexOut main(VertexIn vin)
{
	VertexOut vout;
	
	// Transform to world space space.
	vout.PosW = mul(gWorld, float4(vin.PosL, 1.0f)).xyz;
	vout.NormalW = mul((float3x3)gWorldInvTranspose, vin.NormalL);
		
	// Transform to homogeneous clip space.
	vout.PosH = mul(gWorldViewProj, float4(vin.PosL, 1.0f));

	// Output vertex texture attributes for interpolation across triangle.
	vout.Tex = mul(gTexTransform, float4(vin.Tex, 0.0f, 1.0f)).xy;

	return vout;
}

