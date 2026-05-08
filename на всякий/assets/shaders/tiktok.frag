// youtube shorts, instagram reels, vk clips
// whatever
// ksta ya ne mogu pisat zdes po russki ubit nahuy!!!!!!

#pragma header
uniform vec2 blurSize;
uniform bool enabled;
float Pi = 6.28318530718; // Pi * 2

const vec2 ConstGameSize = vec2(1280.0, 720.0);
// GAUSSIAN BLUR SETTINGS {{{
const float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
const float Quality = 2.5; // BLUR QUALITY (Default 4.0 - More is better but slower)
// GAUSSIAN BLUR SETTINGS }}}

vec4 blur_texture2D(sampler2D bitmap, vec2 uv)
{
	// Pixel colour
	vec4 color = texture2D(bitmap, uv);

	if (blurSize.x > 0.08 || blurSize.y > 0.08)
	{
		vec2 Radius = blurSize / ConstGameSize;
		int samples = 1;
		// Blur calculations
		float stepDir = Pi / Directions;
		float stepQual = 1.0 / Quality;
		for (float d = 0.0; d < Pi; d += stepDir)
		{
			vec2 base = vec2(sin(d), cos(d)) * Radius;
			for (float i = stepQual; i <= 1.0; i += stepQual)
			{
				color += texture2D(bitmap, uv + base * i);
				samples++;
			}
		}
		// Output to screen
		color /= float(samples);
	}

	return color;
}

void main()
{
	float width = openfl_TextureSize.y / 16.0 * 9.0;
	float halfWidthCoord = width / 2.0 / openfl_TextureSize.x;

	// tiktok oda tryasi zhopoy da
	if (openfl_TextureCoordv.x > 0.5 - halfWidthCoord && openfl_TextureCoordv.x < 0.5 + halfWidthCoord)
	{
		gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
	}
	else if (enabled) // blur tiktok oda tryasi zhopoy da
	{
		// need to blur the clip part, so let's scale it
		vec4 color = blur_texture2D(bitmap, (openfl_TextureCoordv - 0.5) / (openfl_TextureSize.x / width) + 0.5);
		color.rgb *= vec3(0.7);
		gl_FragColor = color;
	}
	else // black bars :(
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	}
}