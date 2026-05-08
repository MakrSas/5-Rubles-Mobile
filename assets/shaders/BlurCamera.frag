#pragma header
uniform vec2 blurSize;
float Pi = 6.28318530718; // Pi * 2

const vec2 ConstGameSize = vec2(1280.0, 720.0);
// GAUSSIAN BLUR SETTINGS {{{
const float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
const float Quality = 2.5; // BLUR QUALITY (Default 4.0 - More is better but slower)
// GAUSSIAN BLUR SETTINGS }}}

void main()
{
	// Normalized pixel coordinates (from 0 to 1)
	vec2 uv = openfl_TextureCoordv;
	// Pixel colour
	vec4 color = texture2D(bitmap, uv);

	if (blurSize.x > 0.08 || blurSize.y > 0.08)
	{
		vec2 Radius = blurSize / ConstGameSize;
		float samples = 1.0;
		// Blur calculations
		float stepDir = Pi / Directions;
		float stepQual = 1.0 / Quality;
		for (float d = 0.0; d < Pi; d += stepDir)
		{
			vec2 base = vec2(sin(d), cos(d)) * Radius;
			for (float i = stepQual; i <= 1.0; i += stepQual)
			{
				color += texture2D(bitmap, uv + base * i);
				samples += 1.0;
			}
		}
		// Output to screen
		color /= samples;
	}
	gl_FragColor = color;
}