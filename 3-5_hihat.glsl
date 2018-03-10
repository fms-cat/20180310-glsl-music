#define PI 3.141592654
#define TAU 6.283185307

// ------

vec4 noise( float phase ) {
    vec2 uv = phase / vec2( 0.512, 0.487 );
    return 2.0 * texture( iChannel0, uv ) - 1.0;
}

// ------

vec2 hihat( float time ) {
    float amp = exp( -50.0 * time );
    return amp * noise( time * 100.0 ).xy;
}

// ------

vec2 mainSound( float time ) {
    return vec2( hihat( time ) );
}