#include "Constants.hlsl"

//simple - no lighting and not texture
float4 main(VertexOut pin) : SV_Target
{
	return gMaterial.Diffuse;
}
  
