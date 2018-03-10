#define PI 3.141592654
#define TAU 6.283185307

// ------

float saw( float phase ) {
    return 2.0 * fract( phase ) - 1.0;
}

float square( float phase ) {
    return fract( phase ) < 0.5 ? -1.0 : 1.0;
}

float triangle( float phase ) {
    return 1.0 - 4.0 * abs( fract( phase ) - 0.5 );
}

float sine( float phase ) {
    return sin( TAU * phase );
}

// ------

vec2 mainSound( float time ) {
    return vec2( saw( 440.0 * time ) );
}