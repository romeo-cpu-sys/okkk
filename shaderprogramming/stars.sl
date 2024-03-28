#define snoise(p) (2 * (float noise(p)) - 1)

float fBm(point p; uniform float octaves, lacunarity, gain) {
	uniform float amp = 1;
	varying point pp = p;
	varying float sum = 0;

	uniform float i;
  
	for (i = 0; i < octaves; i += 1) {
		sum += amp * snoise (pp);
		amp *= gain;
		pp *= lacunarity;
	}

	return sum;
}

float turbulence(point p; uniform float octaves, lacunarity, gain) {
	uniform float amp = 1;
	varying point pp = p;
	varying float sum = 0;

	uniform float i;
  
	for (i = 0; i < octaves; i += 1) {
		sum += abs(amp * snoise (pp));
		amp *= gain;
		pp *= lacunarity;
	}

	return sum;
}

void voronoi_f1f2_2d(
	float ss, tt;

	output float f1;
	output float spos1, tpos1;
	output float f2;
	output float spos2, tpos2;
) {
	float jitter = 1.0;

	float sthiscell = floor(ss) + 0.5;
	float tthiscell = floor(tt) + 0.5;

	f1 = f2 = 1000;
	uniform float i, j;

	for (i = -1; i <= 1; i += 1) {
		float stestcell = sthiscell + i;

		for (j = -1; j <= 1; j += 1) {
			float ttestcell = tthiscell + j;

			float spos = stestcell + jitter * (cellnoise(stestcell, ttestcell) - 0.5);
			float tpos = ttestcell + jitter * (cellnoise(stestcell+23, ttestcell-87) - 0.5);

			float soffset = spos - ss;
			float toffset = tpos - tt;

			float dist = soffset*soffset + toffset*toffset;
			
			if (dist < f1) { 
				f2 = f1;
				spos2 = spos1;
				tpos2 = tpos1;

				f1 = dist;
				spos1 = spos;
				tpos1 = tpos;
			}
			else if (dist < f2) {
				f2 = dist;
				spos2 = spos;
				tpos2 = tpos;
			}
		}
	}

  	f1 = sqrt(f1);
	f2 = sqrt(f2);
}


surface stars(
	uniform float globalFrequency = 1.00;
	uniform float starThreshold   = 0.02;

	uniform float cloudMix        = 0.50;
	uniform float starCloudMix    = 0.60;

	uniform color COLOR_STARS   = color(0.20, 0.10, 0.03);
	uniform color COLOR_CLOUD_A = color(0.30, 0.00, 0.80);
	uniform color COLOR_CLOUD_B = color(0.45, 0.00, 0.30);
) {
	// Stars
	float f1;
	voronoi_f1f2_2d(
		s * globalFrequency, t * globalFrequency, f1,
		0, 0, 0, 0, 0
	);
	f1 = smoothstep(starThreshold, starThreshold + 0.05, f1);

	float starBrightness = clamp(
		fBm(P / 5 * globalFrequency, 6.0, 3.0, 0.7), 0, 1
	);
	color stars = COLOR_STARS / (f1 + 0.01) * starBrightness;

	// Clouds
	color cloudA = COLOR_CLOUD_A * clamp(fBm(P / 20.0 * globalFrequency, 6, 3.0, 0.5), 0, 1);
	color cloudB = COLOR_CLOUD_B * clamp(1.0 - turbulence(P / 30.0 * globalFrequency, 6, 1.8, 0.7), 0, 1);
	color cloudColor = mix(cloudA, cloudB, cloudMix);
	
	Ci = mix(stars, cloudColor, starCloudMix);
	Oi = Os;
} 
