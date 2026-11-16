#include "LightHelper.hlsl"


#define MAX_LIGHTS 8		//how many lights can affect a render
#define LIGHT_OFF 0			//off
#define LIGHT_DIR 1			//directional (sun)
#define LIGHT_POINT 2		//point light
#define LIGHT_SPOT 3		//spot light

//constant buffer for things that change only once per frame
cbuffer cbPerFrame : register(b0)  
{
	Light gLights[MAX_LIGHTS];	//all the light data
	float4 gEyePosW;			//ignore w, it's the camera position//ignore w
};

//things that change every time we render a model (object) - the matrices
cbuffer cbPerObject : register(b1)
{
	float4x4 gWorld;
	float4x4 gWorldInvTranspose;
	float4x4 gWorldViewProj;
};

//things that change from one sub-mesh to another, so just the material
cbuffer cbPerMesh : register(b2)
{
	float4x4 gTexTransform;
	Material gMaterial;
}

// Nonnumeric values cannot be added to a cbuffer.

//a texture map
Texture2D gDiffuseMap : register(t0);
//a sampler to access the textyre map, this one does anisotropic filtering 
//on the map so it looks nice
SamplerState samAnisotropic : register(s0);

//data in and out
struct VertexIn
{
	//local space position and normal and texture uv
	float3 PosL		: POSITION;
	float3 NormalL	: NORMAL;
	float2 Tex		: TEXCOORD;
};

struct VertexOut
{
	float4 PosH		: SV_POSITION;	//transformed homogonous space position
	float3 PosW		: POSITION;		//hang onto the world space position
	float3 NormalW	: NORMAL;		//world space normal
	float2 Tex		: TEXCOORD;		//transformed uv
};

