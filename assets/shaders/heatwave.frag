#pragma header

uniform float speed = 1.0;
uniform float waves = 1.0;
uniform float amplitude = 1.0;
uniform float iTime = 0.0;

void main() {
	float base = iTime * speed + length(openfl_TextureCoordv) * waves;
	gl_FragColor = texture2D(bitmap, openfl_TextureCoordv + amplitude * sin(base) + amplitude * cos(base));
}