#define BRIGHTNESS_ARMS    10.0
#define BRIGHTNESS_CENTER   3.0

#define ONE_MINUS(x) (1.0 - (x))

float fBm(point p; uniform float octaves, lacunarity, gain) {
	uniform float amp = 1;
	varying point pp = p;
	varying float sum = 0;

	uniform float i;
  
	for (i = 0; i < octaves; i += 1) {
		sum += amp * noise(pp);
		amp *= gain;
		pp *= lacunarity;
	}

	return sum;
}

surface galaxy(
	uniform float colorMix    = 0.5;
	uniform float armCurve    = 3.0;
	uniform float starFreq    = 40.0;
	uniform float spiralMod   = 1.57;
	uniform float spiralFreq  = 2.0;
	uniform float spiralSpeed = 5.0;

	uniform color COLOR_GALAXY_A      = color(0.2, 0.2, 0.2);
	uniform color COLOR_GALAXY_B      = color(1.0, 1.0, 0.0);
) {
	// Change perspective of galaxy.
	float vc = ( v - 0.1) * 1.5;
	float uu = ( u - 0.5) / ONE_MINUS(vc);
	float vv = (vc - 0.6) / ONE_MINUS(vc);

	// Get distance to center.
	float distc = length((uu, vv, 0));

	// Fade galaxy center based on distance.
	color galaxyCenter = ONE_MINUS(smoothstep(0.0, 0.5, distc));

	// Generate galaxy arms.
	float rays = smoothstep(0.9, 1.0, mod(
		(atan(vv, uu) + distc * armCurve) * spiralFreq, spiralMod
	));

	// Generate stars that will be inside the arms.
	point ppp = point(distc, atan(vv, uu) + distc * spiralSpeed, 0);
	float background = smoothstep(
		0.0, 0.3, ONE_MINUS(fBm(ppp * starFreq, 6.0, 1.8, 0.5))
	);

	// Combine arms and the stars inside them.
	float combined = rays * background * BRIGHTNESS_ARMS;

	// Fade arms with distance.
	combined *= ONE_MINUS(smoothstep(0.1, 0.7, distc));

	// Add galaxy center and color.
	color galaxy = (combined, combined, combined);
	galaxy += galaxyCenter * BRIGHTNESS_CENTER;
	galaxy *= mix(COLOR_GALAXY_A, COLOR_GALAXY_B, colorMix);

	Ci = galaxy;
	Oi = Os * Ci;
} 
