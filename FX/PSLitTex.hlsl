
#include "PSCore.hlsl"

//textured and lit, PSCore does the hard work
float4 main(VertexOut pin) : SV_Target
{
	return PSCore(pin, true);
}

