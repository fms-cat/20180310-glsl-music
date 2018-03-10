#define PI 3.141592654
#define TAU 6.283185307

// ------

float sine( float phase ) {
    return sin( TAU * phase );
}

// ------

vec2 mainSound( float time ) {
    float freq = 440.0;
    float fmamp = 0.1 * exp( -3.0 * time );
    float fm = fmamp * sine( time * freq * 7.0 );
    
    float amp = exp( -1.0 * time );
    return vec2( amp * sine( freq * time + fm ) );
}