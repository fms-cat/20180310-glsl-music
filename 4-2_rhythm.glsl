#define BPM 140.0

#define PI 3.141592654
#define TAU 6.283185307

// ------

float timeToBeat( float t ) { return t / 60.0 * BPM; }
float beatToTime( float b ) { return b / BPM * 60.0; }

// ------

float sine( float phase ) {
    return sin( TAU * phase );
}

vec4 noise( float phase ) {
    vec2 uv = phase / vec2( 0.512, 0.487 );
    return 2.0 * texture( iChannel0, uv ) - 1.0;
}

// ------

float kick( float time ) {
    float amp = exp( -5.0 * time );
    float phase = 50.0 * time
                - 10.0 * exp( -70.0 * time );
    return amp * sine( phase );
}

vec2 hihat( float time ) {
    float amp = exp( -50.0 * time );
    return amp * noise( time * 100.0 ).xy;
}

// ------

vec2 mainSound( float time ) {
    float beat = timeToBeat( time );
    
    float kickTime = beatToTime( mod( beat, 1.0 ) );
    float hihatTime = beatToTime( mod( beat + 0.5, 1.0 ) );
    
    return vec2( kick( kickTime ) + hihat( hihatTime ) );
}