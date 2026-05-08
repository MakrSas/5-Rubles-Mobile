// based on https://www.shadertoy.com/view/l3lcRM
#pragma header

uniform float cellSize = 4.0;
uniform float colors = 8.0;
uniform float crustFactor = 0.4;
#define round(a) floor(a+.5)

void main()
{
	bool zeroCellSize = cellSize <= 0.0;
	vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
	vec2 uv = (zeroCellSize ? fragCoord : round(fragCoord / cellSize) * cellSize) / openfl_TextureSize;

	gl_FragColor = pow(round(pow(texture2D(bitmap, uv), vec4(0.5)) * colors) / colors, vec4(2.0));

	float halfCellSize = cellSize * 0.5;
	vec2 xOffset = vec2(halfCellSize, 0.0) / openfl_TextureSize;
	vec2 yOffset = vec2(0.0, halfCellSize) / openfl_TextureSize;

	vec4 xDiff = texture2D(bitmap, uv + xOffset) - texture2D(bitmap, uv - xOffset);
	vec4 yDiff = texture2D(bitmap, uv + yOffset) - texture2D(bitmap, uv - yOffset);

	vec2 cellUV = (zeroCellSize ? vec2(0.5) : mod((fragCoord + halfCellSize) / cellSize, 1.0));

	gl_FragColor += (mix(-xDiff, xDiff, cellUV.x) + mix(-yDiff, yDiff, cellUV.y)) * crustFactor;
}