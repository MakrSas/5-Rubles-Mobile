#pragma header

// Star Nest by Pablo Roman Andrioli
// License: MIT

#define iterations 17
#define formuparam 0.53

#define volsteps 10
#define stepsize 0.1

#define zoom 0.800
#define tile 0.850
#define speed 0.0007

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850

uniform float iTime = 0.0;
uniform vec2 offsets = vec2(0.0, -1000.0);
uniform vec2 scrollFactor = vec2(0.8, 0.8);

vec2 screenToWorldWithScrollFactor(vec2 screenCoord) {
	float left = uCameraBounds.x;
	float top = uCameraBounds.y;
	float right = uCameraBounds.z;
	float bottom = uCameraBounds.w;
	vec2 scale = vec2(right - left, bottom - top);
	vec2 cameraOffset = vec2(left, top);
	// return screenCoord * scale + (cameraOffset - offsets * scale / uScreenResolution / 4.0) * scrollFactor - scale * (1.0 - scrollFactor) / 2.0;
	return screenCoord * scale + cameraOffset * scrollFactor - scale * (1.0 - scrollFactor) / 2.0; // TODO: Implement offsets
}
void main()
{
	vec2 wpos = screenToWorldWithScrollFactor(openfl_TextureCoordv) / uScreenResolution;
	wpos.y = 1.0 - wpos.y;
	// vec2 wpos = openfl_TextureCoordv;
	//get coords and direction
	vec2 textureSize = uScreenResolution;
	vec2 uv = wpos.xy - 0.5;
	uv.y *= textureSize.y / textureSize.x;
	vec3 dir = vec3(uv * zoom, 1.0);
	float time = iTime * speed + 0.25;

	//mouse rotation
	float a1 = 0.5;
	float a2 = 0.8;
	mat2 rot1 = mat2(cos(a1), sin(a1), -sin(a1), cos(a1));
	mat2 rot2 = mat2(cos(a2), sin(a2), -sin(a2), cos(a2));
	dir.xz *= rot1;
	dir.xy *= rot2;
	vec3 from = vec3(1.0, 0.5, 0.5);
	from += vec3(time * 2.0, time, - 2.0);
	from.xz *= rot1;
	from.xy *= rot2;

	//volumetric rendering
	float s = 0.1, fade = 1.0;
	vec3 v = vec3(0.0);
	for(int r = 0; r < volsteps; r++ ) {
		vec3 p = from + s*dir * 0.5;
		p = abs(vec3(tile) - mod(p, vec3(tile * 2.0))); // tiling fold
		float pa, a = pa = 0.0;
		for(int i = 0; i < iterations; i++ ) {
			p = abs(p) / dot(p, p) - formuparam; // the magic formula
			a += abs(length(p) - pa); // absolute sum of average change
			pa = length(p);
		}
		float dm = max(0.0, darkmatter - a*a * 0.001); // dark matter
		a *= a*a; // add contrast
		if (r > 6) fade *= 1.0 - dm; // dark matter, don't render near
		// v+=vec3(dm,dm*.5,0.);
		v += fade;
		v += vec3(s, s * s, s * s*s * s) * a*brightness * fade; // coloring based on distance
		fade *= distfading; // distance fading
		s += stepsize;
	}
	v = mix(vec3(length(v)), v, saturation); //color adjust
	gl_FragColor = vec4(v * 0.01, 1.0);
}