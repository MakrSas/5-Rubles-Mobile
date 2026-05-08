// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define round(a) floor(a+.5)
#define texture texture2D

// end of ShadertoyToFlixel header
// based on https://www.shadertoy.com/view/McdSzl

uniform float Q = 4.;
uniform int BS = 8; // multiples of 8 work better and much neater
const int COLOR_SPACE = 1;

// #define modulo(a, b) a - (b * floor(a/b))
float modulo(float a, float b) {
	return a - (b * floor(a/b));
}

vec3 toYCbCr(in vec3 rgb) {
	return vec3(0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b,
	-0.1687 * rgb.r - 0.3313 * rgb.g + 0.5 * rgb.b,
	0.5 * rgb.r - 0.4187 * rgb.g - 0.0813 * rgb.b);
}

vec3 toRGB(in vec3 ycbcr) {
	return vec3(ycbcr.x + 1.402 * ycbcr.z,
	ycbcr.x - 0.344136 * ycbcr.y - 0.714136 * ycbcr.z,
	ycbcr.x + 1.772 * ycbcr.y);
}

float dct(float u, float v, float x, float y) {
	const float PI = asin(1.) * 2.;
	const float S1D2 = sqrt(.5);
	float HFRQ = 1.;
	float VFRQ = 1.;
	return ((u == 0.) ? S1D2 : HFRQ) * ((v == 0.) ? S1D2 : VFRQ) * cos((2. * x + 1.) * u * PI / 16.) * cos((2. * y + 1.) * v * PI / 16.);
}

void main() {
	vec2 I = openfl_TextureCoordv*openfl_TextureSize;
	int GS = BS;

	vec2 blockCoord = vec2(I) / float(BS);
	vec3 block[64];
	for (int i = 0; i < 64; ++i) {
		float x = modulo(float(i), 8.), y = i / 8.; // i % 8
			block[i] = texture(iChannel0, (vec2(blockCoord * float(BS) + vec2(x*float(BS/8), y*float(BS/8))))/ iResolution.xy).rgb;
	}

	vec3 DCTBlock[64];
	for (int u = 0; u < 8; ++u) {
		for (int v = 0; v < 8; ++v) {
			vec3 sum = vec3(0.);
			for (int i = 0; i < 64; ++i) {
				float x = modulo(float(i), 8.), y = i / 8.; // i % 8
				sum += block[i] * dct(float(u), float(v), x, y);
			}

			DCTBlock[u + v * 8] = sum / 4.;
			if (COLOR_SPACE == 1) {
				vec3 ycbcr = toYCbCr(DCTBlock[u + v * 8]);
				DCTBlock[u + v * 8] = toRGB(vec3(round(ycbcr.r * Q), round(ycbcr.g * Q), round(ycbcr.b * Q)));
			} else {
				DCTBlock[u + v * 8] = vec3(round(DCTBlock[u + v * 8].r * Q), round(DCTBlock[u + v * 8].g * Q), round(DCTBlock[u + v * 8].b * Q));
			}
		}
	}

	int index = int(mod(I.x, float(BS))) + int(mod(I.y, float(BS))) * BS;
	float posX = modulo(float(index), float(BS)), posY = float(index) / float(BS); // index % BS

	vec3 r = vec3(0.);
	for (int i = 0; i < 64; ++i) {
		float ux = modulo(float(i), 8.), vy = i / 8.; // i % 8
		r += /*DCTBlock[int(ux + vy * 8.)] */ dct(ux*(8.0/float(GS)), vy*(8.0/float(GS)), posX, posY);
	}

	gl_FragColor = vec4(r / (Q * 4.), 1.);

	// O = vec4(1., 0., 0., 1.);
}