#define PI 3.141592654
#define TAU 6.283185307

// ------

float sine( float phase ) {
    return sin( TAU * phase );
}

// ------

float kick( float time ) {
    float amp = exp( -5.0 * time );
    float phase = 50.0 * time
                - 10.0 * exp( -70.0 * time );
    return amp * sine( phase );
}

// ------

vec2 mainSound( float time ) {
    return vec2( kick( time ) );
}