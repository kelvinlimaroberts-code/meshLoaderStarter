
#include "PSCore.hlsl"

//simple - lighting, but no texture. PSCore does all the work.
float4 main(VertexOut pin) : SV_Target
{
	return PSCore(pin, false);
}

