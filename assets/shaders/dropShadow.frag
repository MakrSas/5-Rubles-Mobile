#pragma header

uniform vec4 multColor = vec4(0.686, 0.294, 0.341, 0.51); // todo: 0-255 range?
uniform vec2 offset = vec2(-20.0, 20.0);
uniform vec4 frameUv = vec4(0.0);
uniform int iBlendMode = 9;
uniform bool rimLightMode;

uniform float BLMODE_SHADER_outsideFactor = 0.1;

// TODO: MORE ACCURATE

const int BLMODE_ADD = 0;
const int BLMODE_ALPHA = 1; // TODO
const int BLMODE_DARKEN = 2;
const int BLMODE_DIFFERENCE = 3;
const int BLMODE_ERASE = 4;
const int BLMODE_HARDLIGHT = 5;
const int BLMODE_INVERT = 6;
const int BLMODE_LAYER = 7; // TODO
const int BLMODE_LIGHTEN = 8;
const int BLMODE_MULTIPLY = 9;
const int BLMODE_NORMAL = 10; // please don't
const int BLMODE_OVERLAY = 11;
const int BLMODE_SCREEN = 12;
const int BLMODE_SHADER = 13; // let's say it's an alpha inversion.
const int BLMODE_SUBTRACT = 14;

const vec3 CONST_UNSUPPORTEDED_COLOR = vec3(1.0, 0.0, 1.0);
const vec3 CONST_VEC3_0 = vec3(0.0);
const vec3 CONST_VEC3_1 = vec3(1.0);
const vec4 CONST_VEC4_0 = vec4(0.0);
const vec4 CONST_VEC4_1 = vec4(1.0);

uniform float hue = 0;
uniform float saturation = 0;
uniform float brightness = 0;
uniform float contrast = 0;

const vec3 grayscaleValues = vec3(0.3098039215686275, 0.607843137254902, 0.0823529411764706);
const float e = 2.718281828459045;

vec4 blendNormalAlphas(vec4 bg, vec4 src) {
	return mix(bg, src, src.a);
}

vec3 blendSubtract(vec3 base, vec3 blend) {
	return max(base.rgb+blend.rgb-CONST_VEC3_1, CONST_VEC3_0);
}
vec3 blendScreen(vec3 base, vec3 blend) {
	return CONST_VEC3_1 - (CONST_VEC3_1 - base) * (CONST_VEC3_1 - blend);
}

float overlay(float s, float d) {
	return d < 0.5 ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
}

vec4 blendThing(vec4 src, vec4 dst, vec3 blendResult) {
	return vec4(
		(
			src.rgb * (1.0 - dst.a) +
			blendResult * dst.a
		),
		src.a
	);
}

vec4 blendOverlay(vec4 base, vec4 blend) {
	return blendThing(base, blend, vec3(
			overlay(base.r, blend.r),
			overlay(base.g, blend.g),
			overlay(base.b, blend.b)
		));
}

vec4 blendDarken(vec4 base, vec4 blend) {
	return blendThing(base, blend, min(base.rgb, blend.rgb));
}

vec4 blendLighten(vec4 base, vec4 blend) {
	return blendThing(base, blend, max(base.rgb, blend.rgb));
}

vec4 blendHardLight(vec4 base, vec4 blend) {
	return blendThing(base, blend, vec3(
			overlay(blend.r, base.r),
			overlay(blend.g, base.g),
			overlay(blend.b, base.b)
		));
}

vec4 blendShader(vec4 base, vec4 blend) {
	return vec4(
		(
			mix(blend.rgb + BLMODE_SHADER_outsideFactor * base.rgb, base.rgb, blend.a)
		),
		base.a
	);
	// return blendThing(base, blend, (blend.rgb / blend.a));
}

vec4 blend(vec4 bg, vec4 src) {
	if (iBlendMode == BLMODE_ADD) {
		return min(bg + src, CONST_VEC4_1);
	} else
	if (iBlendMode == BLMODE_DARKEN) {
		return blendDarken(bg, src);
	} else
	if (iBlendMode == BLMODE_DIFFERENCE) {
		bg.rgb = abs(bg.rgb-src.rgb);
		return bg;
	} else
	if (iBlendMode == BLMODE_ERASE) {
		bg.rgb = bg.rgb - src.rgb;
		return bg;
	} else
	if (iBlendMode == BLMODE_HARDLIGHT) {
		return blendHardLight(bg, src);
	} else
	if (iBlendMode == BLMODE_INVERT) {
		return blendThing(bg, src, (CONST_VEC3_1 - bg.rgb));
	} else
	if (iBlendMode == BLMODE_LIGHTEN) {
		return blendLighten(bg, src);
	} else
	if (iBlendMode == BLMODE_MULTIPLY) {
		bg.rgb = bg.rgb * src.rgb;
		return bg;
	} else
	if (iBlendMode == BLMODE_NORMAL) {
		return bg * (CONST_VEC4_1 - src.aaaa) + src;
	} else
	if (iBlendMode == BLMODE_OVERLAY) {
		return blendOverlay(bg, src);
	} else
	if (iBlendMode == BLMODE_SHADER) {
		return blendShader(bg, src);
	} else
	if (iBlendMode == BLMODE_SCREEN) {
		return vec4(blendScreen(bg.rgb, src.rgb), blendNormalAlphas(bg, src));
	} else
	if (iBlendMode == BLMODE_SUBTRACT) {
		return vec4(blendSubtract(bg.rgb, src.rgb), blendNormalAlphas(bg, src));
	} else
	{
		// not supported blend
		return blendThing(bg, src, CONST_UNSUPPORTEDED_COLOR * bg.rgb + src.rgb);
	}
}

vec3 applyHueRotate(vec3 aColor, float aHue) {
	float angle = radians(aHue);

	mat3 m1 = mat3(0.213, 0.213, 0.213, 0.715, 0.715, 0.715, 0.072, 0.072, 0.072);
	mat3 m2 = mat3(0.787, -0.213, -0.213, -0.715, 0.285, -0.715, -0.072, -0.072, 0.928);
	mat3 m3 = mat3(-0.213, 0.143, -0.787, -0.715, 0.140, 0.715, 0.928, -0.283, 0.072);
	mat3 m = m1 + cos(angle) * m2 + sin(angle) * m3;

	return m * aColor;
}

vec3 applySaturation(vec3 aColor, float value) {
	if (value > 0.0)
	{
		value = value * 3.0;
	}
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

bool inFrame(vec2 uv) {
	return frameUv == CONST_VEC4_0 || (uv.x >= frameUv.x && uv.x <= frameUv.z && uv.y >= frameUv.y && uv.y <= frameUv.w);
}

void main() {
	// base color
	vec4 color = flixel_applyColorTransform(applyHSBCEffect(texture2D(bitmap, openfl_TextureCoordv)));

	if (color.a > 0.0) {
		// get mask uv
		vec2 uv = openfl_TextureCoordv + offset / openfl_TextureSize;
		// get mask alpha
		float trans = (inFrame(uv) ? flixel_texture2D(bitmap, uv).a : 0.0); // float(inFrame(uv)) * flixel_texture2D(bitmap, uv).a
		// invert on rimLightMode = true
		trans = abs(float(rimLightMode) - trans);
		// blend color
		color.rgb = mix(color.rgb, blend(color, multColor).rgb, multColor.a * color.a * trans);
	}

	// display color
	gl_FragColor = color;
}