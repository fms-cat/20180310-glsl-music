#define PI 3.141592654
#define TAU 6.283185307

// ------

float saw( float phase ) {
    return 2.0 * fract( phase ) - 1.0;
}

float sine( float phase ) {
    return sin( TAU * phase );
}

// ------

vec2 mainSound( float time ) {
    float vib = 0.2 * sine( time * 5.0 );
    return vec2( saw( 440.0 * time + vib ) );
}