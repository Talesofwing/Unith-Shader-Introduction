#ifndef ZERO_INCLUDED
#define ZERO_INCLUDED

inline float3 Refract (float3 i, float3 n, float eta) {
	float cosi = dot (-i, n);
	float cost2 = 1.0f - eta * eta * (1.0f - cosi * cosi);
	float3 t = eta * i + ((eta * cosi - sqrt(abs(cost2))) * n);
	return t * (float3)(cost2 > 0);
}

inline fixed luminance (fixed4 color) {
	return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
}

#endif