#pragma header

// pattern stuff
uniform sampler2D bgTexture;
uniform vec4 bgFrameData; // (x, y) = trimmed l/t offset | (z, w) = texture size
uniform vec4 bgFrameUV;
uniform vec2 bgScale = vec2(1.0);
uniform vec2 bgOffset = vec2(0.0);
uniform vec4 spriteFrameData; // (x, y) = trimmed l/t offset | (z, w) = texture size
uniform vec4 spriteFrameUV;
uniform bool spriteFlipX;
uniform bool spriteFlipY;

uniform float hue;
uniform float saturation;
uniform float brightness;
uniform float contrast;

const vec3 grayscaleValues = vec3(0.3098039215686275, 0.607843137254902, 0.0823529411764706);
const float e = 2.718281828459045;

vec3 applyHueRotate(vec3 aColor, float aHue) {
	float angle = radians(aHue);

	mat3 m1 = mat3(0.213, 0.213, 0.213, 0.715, 0.715, 0.715, 0.072, 0.072, 0.072);
	mat3 m2 = mat3(0.787, - 0.213, - 0.213, - 0.715, 0.285, - 0.715, - 0.072, - 0.072, 0.928);
	mat3 m3 = mat3(-0.213, 0.143, - 0.787, - 0.715, 0.140, 0.715, 0.928, - 0.283, 0.072);
	mat3 m = m1 + cos(angle) * m2 + sin(angle) * m3;

	return m * aColor;
}

vec3 applySaturation(vec3 aColor, float value) {
	if (value > 0.0) { value = value * 3.0; }
	value = (1.0 + (value / 100.0));
	vec3 grayscale = vec3(dot(aColor, grayscaleValues));
	return clamp(mix(grayscale, aColor, value), 0.0, 1.0);
}

vec3 applyContrast(vec3 aColor, float value) {
	value = (1.0 + (value / 100.0));
	if (value > 1.0) {
		value = (((0.00852259 * pow(e, 4.76454 * (value - 1.0))) * 1.01) - 0.0086078159) * 10.0; //Just roll with it...
		value += 1.0;
	}
	return clamp((aColor - 0.25) * value + 0.25, 0.0, 1.0);
}

vec3 applyHSBCEffect(vec3 color) {

	//Brightness
	color = color + brightness / 255.0;

	//Hue
	if (hue != 0.0)
		color = applyHueRotate(color, hue);

	//Contrast
	if (contrast != 0.0)
		color = applyContrast(color, contrast);

	//Saturation
	if (saturation != 0.0)
		color = applySaturation(color, saturation);

	return color;
}

vec4 applyHSBCEffect(vec4 textureColor) {

	// Un-multiply alpha if the texture is premultiplied
	// Lime premultiplies alphas before sending it to render, so we want to accomodate header. This fixes some antialiased edges appearing darker
	vec3 unpremultipliedColor = textureColor.a != 0.0 ? textureColor.rgb / textureColor.a : textureColor.rgb;

	// Apply effects to the unpremultiplied color
	vec3 outColor = applyHSBCEffect(unpremultipliedColor);

	return vec4(outColor * textureColor.a, textureColor.a);
}

void main()
{
	vec4 col = texture2D(bitmap, openfl_TextureCoordv);

	float maxrb = max( col.r, col.b );
	maxrb = pow(maxrb, 0.8 - maxrb);

	float k = clamp( (col.g-maxrb), 0.0, 1.0 );

	float dg = col.g;
	col.g = min( col.g, maxrb );
	col.rgb -= pow(dg - col.g, 2.0);

	// stolen from pizza tower lol
	// - rich

	// convert to (0,0) and convert to integer size in texture page
	vec2 pos = (openfl_TextureCoordv - spriteFrameUV.xy) * spriteFrameData.zw;
	// get the edges of the palette sprite and convert to integer size in texture page
	// vec2 edge = (bgFrameUV.zw - bgFrameUV.xy) * bgFrameData.zw;

	// wrap around the edges
	// pos = mod((pos + spriteFrameData.xy) / bgScale, edge + bgFrameData.xy);
	pos = (pos + spriteFrameData.xy) / bgScale;

	// convert the position back to texel size
	pos /= bgFrameData.zw;

	// set the tex coordinate
	vec2 texcoord = vec2(spriteFlipX ? bgFrameUV.z - pos.x : bgFrameUV.x + pos.x, spriteFlipY ? bgFrameUV.w - pos.y : bgFrameUV.y + pos.y);
	vec4 bg_col = texture2D(bgTexture, texcoord - bgOffset / openfl_TextureSize);

	gl_FragColor = flixel_applyColorTransform(applyHSBCEffect(vec4( mix(col.rgb, bg_col.rgb, k), col.a )));
}