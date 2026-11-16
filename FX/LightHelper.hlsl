//matches the light structure on the gpu
struct Light
{
	float4 Ambient;
	float4 Diffuse;
	float4 Specular;	
	float4 Direction;	//igniore w
	float4 Position;	//position=xyz
	float4 Attenuation;	//attenuation=xyz
	int Type;	// none=0, direction=1, point=2, spot=3
	float Range;//stop after this distance from the light source
	float Theta;//inner cone theta
	float Phi;	//outer cone phi
};

//matches the material structure on the gpu
struct Material
{
	float4 Diffuse;
	float4 Ambient;
	float4 Specular; //w = SpecPower
};
//handy constant
static const float PI = 3.14159265f;

/*
* a directional light like the sun
* mat - IN material
* L - IN light data
* normal - surface geometry normal
* toEye - normal pointing to the camera
* ambient, diffuse, spec - light intensities
*/
void ComputeDirectionalLight(Material mat, Light L,
	float3 normal, float3 toEye,
	out float4 ambient,
	out float4 diffuse,
	out float4 spec)
{
	// Initialize outputs.
	ambient = float4(0.0f, 0.0f, 0.0f, 0.0f);
	diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
	spec = float4(0.0f, 0.0f, 0.0f, 0.0f);

	// The light vector aims opposite the direction the light rays travel.
	float3 lightVec = -L.Direction.xyz;

	// Add ambient term.
	ambient = mat.Ambient * L.Ambient;

	// Add diffuse and specular term, provided the surface is in 
	// the line of site of the light.

	float diffuseFactor = dot(lightVec, normal);

	// Flatten to avoid dynamic branching.
	[flatten]
	if (diffuseFactor > 0.0f)
	{
		float3 v = reflect(-lightVec, normal);
		float specFactor = pow(max(dot(v, toEye), 0.0f), mat.Specular.w);

		diffuse = diffuseFactor * mat.Diffuse * L.Diffuse;
		spec = specFactor * mat.Specular * L.Specular;
	}
}



/*
* Same parameters as directional light, but this is a point light so it has a position and shines in all directions
* pos - this is the only extra parameter and defines a world position point on the geometry that we are trying to light
*/
void ComputePointLight(Material mat, Light L, float3 pos, float3 normal, float3 toEye,
	out float4 ambient, out float4 diffuse, out float4 spec)
{
	// Initialize outputs.
	ambient = float4(0.0f, 0.0f, 0.0f, 0.0f);
	diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
	spec = float4(0.0f, 0.0f, 0.0f, 0.0f);

	// The vector from the surface to the light.
	float3 lightVec = L.Position.xyz - pos;

	// The distance from surface to light.
	float d = length(lightVec);

	// Range test.
	if (d > L.Range)
		return;

	// Normalize the light vector.
	lightVec /= d;

	// Ambient term.
	ambient = mat.Ambient * L.Ambient;

	// Add diffuse and specular term, provided the surface is in 
	// the line of site of the light.

	float diffuseFactor = dot(lightVec, normal);

	// Flatten to avoid dynamic branching.
	//[flatten]
	if (diffuseFactor > 0.0f)
	{
		float3 v = reflect(-lightVec, normal);
		float specFactor = pow(max(dot(v, toEye), 0.0f), mat.Specular.w);

		diffuse = diffuseFactor * mat.Diffuse * L.Diffuse;
		spec = specFactor *mat.Specular * L.Specular;
	}

	// Attenuate
	float att = 1.0f / dot(L.Attenuation.xyz, float3(1.0f, d, d*d));

	diffuse *= att;
	spec *= att;
}

 
/*
* a spotlight, it has a position and a direction, then it shines a cone of light in that direction
* same parameters as point light
*/
void ComputeSpotLight(Material mat, Light L, float3 pos, float3 normal, float3 toEye,
	out float4 ambient, out float4 diffuse, out float4 spec)
{
	// Initialize outputs.
	ambient = float4(0.0f, 0.0f, 0.0f, 0.0f);
	diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
	spec = float4(0.0f, 0.0f, 0.0f, 0.0f);

	// The vector from the surface to the light.
	float3 lightVec = L.Position.xyz - pos;

	// The distance from surface to light.
	float d = length(lightVec);

	// Range test.
	if (d > L.Range)
		return;

	// Normalize the light vector.
	lightVec /= d;

	// Ambient term.
	ambient = mat.Ambient * L.Ambient;

	// Add diffuse and specular term, provided the surface is in 
	// the line of site of the light.

	float diffuseFactor = dot(lightVec, normal);

	// Flatten to avoid dynamic branching.
	[flatten]
	if (diffuseFactor > 0.0f)
	{
		float3 v = reflect(-lightVec, normal);
		float specFactor = pow(max(dot(v, toEye), 0.0f), mat.Specular.w);

		diffuse = diffuseFactor * mat.Diffuse * L.Diffuse;
		spec = specFactor * mat.Specular * L.Specular;
	}

	// Scale by spotlight factor and attenuate.
	float spot = 0;
	float angle = acos(dot(-lightVec, L.Direction.xyz));
	[flatten]
	if (angle < L.Theta) //THETA
		spot = 1.0f;
	else if (angle < L.Phi)	//PHI
		//smooth step phi->theta
		spot = smoothstep(L.Phi, L.Theta, angle);

	// Scale by spotlight factor and attenuate.
	float att = spot / dot(L.Attenuation.xyz, float3(1.0f, d, d*d));

	ambient *= spot;
	diffuse *= att;
	spec *= att;
}
